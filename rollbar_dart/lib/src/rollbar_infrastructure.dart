import 'dart:core';
import 'dart:isolate';

import 'package:meta/meta.dart';
import 'package:rollbar_dart/rollbar_dart.dart';

import 'ext/tuple.dart';
import 'ext/math.dart';
import 'sender/http_sender.dart';

@sealed
@immutable
class Infrastructure {
  final ReceivePort _receivePort;
  final SendPort _sendPort;
  final Isolate _isolate;

  Infrastructure._(this._isolate, this._receivePort, this._sendPort);

  Future<void> dispose() async {
    _sendPort.send(null);
    _receivePort.close();
    _isolate.kill(priority: Isolate.beforeNextEvent);
  }

  void process({required PayloadRecord record}) {
    _sendPort.send(record);
  }
}

extension InfrastructureIsolate on Infrastructure {
  static late ConnectivityMonitor connectivity;
  static late PayloadRepository repository;

  static Future<Infrastructure> spawn({required Config config}) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      work,
      Tuple2(receivePort.sendPort, config.persistPayloads),
    );
    final sendPort = await receivePort.first;
    return Infrastructure._(isolate, receivePort, sendPort);
  }

  static Future<void> work(Tuple2<SendPort, bool> initial) async {
    final sendPort = initial.first;
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    final shouldPersistPayloads = initial.second;
    connectivity = ConnectivityMonitor();
    repository = PayloadRepository(persistent: shouldPersistPayloads);

    await processPendingRecords();

    await for (final PayloadRecord? record in receivePort) {
      if (record == null) {
        await processPendingRecords();
        break;
      }

      repository.addPayloadRecord(record);
      await processPendingRecords();
    }
  }

  static Future<void> processPendingRecords() async {
    for (final record in repository.payloadRecords) {
      final sender = HttpSender(
        endpoint: record.endpoint,
        accessToken: record.accessToken,
      );

      if (!await processPendingRecord(record, sender)) {
        break;
      }
    }
  }

  static Future<bool> processPendingRecord(
    PayloadRecord record,
    Sender sender,
  ) async {
    if (!connectivity.connectivityState.connectivityOn) {
      return false;
    }

    return await sender.sendString(record.payloadJson).then((success) {
      if (success) {
        repository.removePayloadRecord(id: record.id);
        return true;
      }

      if (connectivity.connectivityState.connectivityOn) {
        connectivity.overrideAsOffFor(duration: 30.seconds);
      }

      final cutoffTime = DateTime.now().toUtc().subtract(1.days);
      if (record.timestamp.compareTo(cutoffTime) < 0) {
        repository.removePayloadRecord(id: record.id);
      }

      return false;
    });
  }
}
