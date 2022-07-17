import 'dart:core';
import 'dart:isolate';

import 'package:meta/meta.dart';
import 'package:rollbar_dart/rollbar_dart.dart';

import 'ext/tuple.dart';
import 'sender/http_sender.dart';

class RollbarInfrastructure {
  final ReceivePort _receivePort;
  final SendPort _sendPort;
  final Isolate _isolate;

  RollbarInfrastructure._(this._isolate, this._receivePort, this._sendPort);

  static Future<RollbarInfrastructure> start({required Config config}) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      work,
      Tuple2(receivePort.sendPort, config.persistPayloads),
    );

    final sendPort = await receivePort.first;
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
}

extension InfrastructureIsolate on RollbarInfrastructure {
  static late ConnectivityMonitor connectivity;
  static late PayloadRepository repository;

  @internal
  static Future<void> work(Tuple2<SendPort, bool> initial) async {
    final sendPort = initial.first;
    final infrastructurePort = ReceivePort();
    sendPort.send(infrastructurePort.sendPort);

    final shouldPersistPayloads = initial.second;
    connectivity = ConnectivityMonitor();
    repository = PayloadRepository(persistent: shouldPersistPayloads);

    await _processAllPendingRecords();

    // Wait for messages from the main isolate.
    await for (final message in infrastructurePort) {
      bool continueProcessing = await _process(message);
      if (!continueProcessing) {
        break;
      }
    }
  }

  static Future<bool> _process(dynamic message) async {
    if (message == null) {
      await _processAllPendingRecords();
      return false;
    }

    switch (message.runtimeType) {
      case PayloadRecord:
        await _processPayloadRecord(message);
    }

    return true;
  }

  static Future<void> _processPayloadRecord(PayloadRecord payloadRecord) async {
    repository.addPayloadRecord(payloadRecord);
    await _processDestinationPendingRecords(
        payloadRecord.destination, repository);
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
    if (!connectivity.connectivityState.connectivityOn) {
      return false;
    }

    final success = await sender.sendString(record.payloadJson);
    if (success) {
      repo.removePayloadRecord(record);
      return true;
    } else {
      if (connectivity.connectivityState.connectivityOn) {
        connectivity.overrideAsOffFor(duration: Duration(seconds: 30));
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
    if (repository.destinations.isNotEmpty) {
      for (final destination in repository.destinations) {
        await _processDestinationPendingRecords(destination, repository);
      }

      await repository.removeUnusedDestinationsAsync();
    }
  }
}
