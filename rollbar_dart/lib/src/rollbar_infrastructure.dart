import 'dart:core';
import 'dart:isolate';
import 'dart:developer';

import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';
import 'package:rollbar_dart/rollbar_dart.dart';

import 'ext/module.dart';
import 'sender/http_sender.dart';

class RollbarInfrastructure {
  final ReceivePort _receivePort;
  final SendPort _sendPort;
  final Isolate _isolate;

  RollbarInfrastructure._(this._isolate, this._receivePort, this._sendPort);

  static Future<RollbarInfrastructure> start({required Config config}) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(work, receivePort.sendPort);
    final sendPort = await receivePort.first;
    sendPort.send(config.toMap());
    return RollbarInfrastructure._(isolate, receivePort, sendPort);
  }

  Future<void> dispose() async {
    // Send a signal to the spawned isolate indicating that it should exit:
    _sendPort.send(null);
    _receivePort.close();
    _isolate.kill(priority: Isolate.beforeNextEvent);
  }

  //static final RollbarInfrastructure instance = RollbarInfrastructure._();

  void process({required PayloadRecord record}) {
    _sendPort.send(record);
  }

  @internal
  static Future<void> work(SendPort sendPort) async {
    final infrastructurePort = ReceivePort();
    sendPort.send(infrastructurePort.sendPort);

    // Wait for messages from the main isolate.
    await for (final message in infrastructurePort) {
      bool continueProcessing = await _process(message);
      if (!continueProcessing) {
        break;
      }
    }

    //Isolate.current.kill(priority: Isolate.immediate);
    //Isolate.exit();
  }

  static Future<bool> _process(dynamic message) async {
    // [HACK] This delay helps to avoid occasional sqlite's "db locked"
    // errors/exceptions. Keep it until we figure out why sqlite has these
    // errors randomly:
    await Future.delayed(Duration(milliseconds: 25));

    if (message == null) {
      await _processAllPendingRecords();
      return false;
    }

    switch (message.runtimeType) {
      case Config:
        _processConfig(message);
        await _processAllPendingRecords();
        break;
      case PayloadRecord:
        await _processPayloadRecord(message);
    }

    return true;
  }

  static void _processConfig(Config config) {
    if (ServiceLocator.instance.registrationsCount > 0) return;

    ServiceLocator.instance.register<PayloadRepository, PayloadRepository>(
      PayloadRepository.create(config.persistPayloads),
    );
    ServiceLocator.instance.register<Sender, HttpSender>(
      HttpSender(endpoint: config.endpoint, accessToken: config.accessToken),
    );
    ServiceLocator.instance
        .register<ConnectivityMonitoring, ConnectivityMonitor>(
      ConnectivityMonitor(),
    );
  }

  static Future<void> _processPayloadRecord(PayloadRecord payloadRecord) async {
    final repo = ServiceLocator.instance.tryResolve<PayloadRepository>();
    if (repo != null) {
      repo.addPayloadRecord(payloadRecord);
      await _processDestinationPendingRecords(payloadRecord.destination, repo);
    } else {
      ModuleLogger.moduleLogger.severe('PayloadRepository not registered');
      await HttpSender(
        endpoint: payloadRecord.destination.endpoint,
        accessToken: payloadRecord.destination.accessToken,
      ).sendString(payloadRecord.payloadJson);
    }
  }

  static Future<void> _processDestinationPendingRecords(
    Destination destination,
    PayloadRepository repo,
  ) async {
    final records =
        await repo.getPayloadRecordsForDestinationAsync(destination);
    if (records.isEmpty) {
      return;
    }

    final sender = HttpSender(
      endpoint: destination.endpoint,
      accessToken: destination.accessToken,
    );

    for (var record in records) {
      if (!await _processPendingRecord(record, sender, repo)) {
        break;
      }
    }
  }

  static Future<bool> _processPendingRecord(
    PayloadRecord record,
    Sender sender,
    PayloadRepository repo,
  ) async {
    final connectivityMonitor =
        ServiceLocator.instance.tryResolve<ConnectivityMonitoring>();
    if (connectivityMonitor?.connectivityState.connectivityOn != true) {
      return false;
    }

    final success = await sender.sendString(record.payloadJson);
    if (success) {
      repo.removePayloadRecord(record);
      return true;
    } else {
      if (connectivityMonitor != null &&
          connectivityMonitor.connectivityState.connectivityOn) {
        connectivityMonitor.overrideAsOffFor(duration: Duration(seconds: 30));
      }
      final cutoffTime =
          DateTime.now().toUtc().subtract(const Duration(days: 1));
      if (record.timestamp.compareTo(cutoffTime) < 0) {
        repo.removePayloadRecord(record);
      }
      return false;
    }
  }

  static Future<void> _processAllPendingRecords() async {
    final repository = ServiceLocator.instance.tryResolve<PayloadRepository>();

    if (repository != null && repository.destinations.isNotEmpty == true) {
      for (final destination in repository.destinations) {
        await _processDestinationPendingRecords(destination, repository);
      }

      await repository.removeUnusedDestinationsAsync();
    }
  }
}
