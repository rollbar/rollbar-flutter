import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

import '../config.dart';
import '../persistence.dart';
import 'sender.dart';
import 'http_sender.dart';

/// A [Sender] that persists payloads and defers its transport in case of
/// client connectivity issues, temporary server errors, or interruptions.
@sealed
@immutable
@internal
class PersistentHttpSender
    with Persistence<PayloadRecord>
    implements Configurable, Sender {
  @override
  final Config config;

  PersistentHttpSender(this.config);

  @override
  Future<bool> send(JsonMap payload) async => sendString(jsonEncode(payload));

  @override
  Future<bool> sendString(String payload) async {
    records.add(PayloadRecord(
      accessToken: config.accessToken,
      endpoint: config.endpoint,
      payload: payload,
    ));

    for (final record in records) {
      final success = await HttpSender.sendRecord(record);
      final expiration = DateTime.now().toUtc() - config.persistenceLifetime;

      if (success || record.timestamp < expiration) {
        records.remove(record);
      }

      if (!success) return false;
    }

    return true;
  }
}
