import 'dart:convert';
import 'dart:developer';

import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

import '../config.dart';
import 'sender.dart';
import 'http_sender.dart';

/// Persistent [Sender]. Default [Sender] implementation.
@sealed
@immutable
class PersistentSender implements Sender {
  final Config _config;
  final TableSet<PayloadRecord> _payloadRecords;

  PersistentSender(this._config)
      : _payloadRecords = TableSet(isPersistent: _config.persistPayloads);

  @override
  Future<bool> send(JsonMap payload) async => sendString(jsonEncode(payload));

  @override
  Future<bool> sendString(String payload) async {
    try {
      final newRecord = PayloadRecord(
          accessToken: _config.accessToken,
          endpoint: _config.endpoint,
          config: jsonEncode(_config.toMap()),
          payload: payload);

      _payloadRecords.add(newRecord);

      for (final record in _payloadRecords) {
        final success = await HttpSender.sendRecord(record);

        if (success || record.timestamp < DateTime.now().toUtc() - 1.days) {
          _payloadRecords.remove(record);
        }

        if (!success) return false;
      }

      return true;
    } catch (error, stackTrace) {
      log('Error persisting payload: $error =>\n$stackTrace');
      return false;
    }
  }
}
