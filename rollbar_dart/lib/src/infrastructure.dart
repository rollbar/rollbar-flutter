import 'dart:core';
import 'dart:isolate';

import 'package:meta/meta.dart';
import 'package:rollbar_dart/rollbar_dart.dart';

import 'ext/object.dart';
import 'ext/tuple.dart';
import 'ext/math.dart';
import 'ext/date_time.dart';
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
  static late PayloadRecordDatabase payloadRecords;

  static Future<Infrastructure> spawn({required Config config}) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
        work, Tuple2(receivePort.sendPort, config.persistPayloads));
    final sendPort = await receivePort.first;
    return Infrastructure._(isolate, receivePort, sendPort);
  }

  static Future<void> work(Tuple2<SendPort, bool> tuple) async {
    final sendPort = tuple.first;
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    final shouldPersistPayloads = tuple.second;
    connectivity = ConnectivityMonitor();
    payloadRecords = PayloadRecordDatabase(isPersistent: shouldPersistPayloads);

    await processPendingRecords();

    await for (final PayloadRecord? record in receivePort) {
      record.map(payloadRecords.add);
      await processPendingRecords();
      if (record == null) break;
    }
  }

  static Future<void> processPendingRecords() async {
    for (final record in payloadRecords) {
      if (!connectivity.connectivityState.connectivityOn) {
        break;
      }

      final sender = HttpSender(
        endpoint: record.endpoint,
        accessToken: record.accessToken,
      );

      final success = await sender.sendString(record.payload);

      if (success) {
        payloadRecords.remove(record);
      } else {
        if (connectivity.connectivityState.connectivityOn) {
          connectivity.overrideAsOffFor(duration: 30.seconds);
        }

        if (record.timestamp < DateTime.now().toUtc() - 1.days) {
          payloadRecords.remove(record);
        }

        break;
      }
    }
  }
}
