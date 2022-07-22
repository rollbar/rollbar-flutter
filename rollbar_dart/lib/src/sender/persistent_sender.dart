import 'dart:convert';
import 'dart:developer';

import 'package:meta/meta.dart';

import '../ext/collection.dart';
import '../../rollbar.dart';

/// Persistent [Sender]. Default [Sender] implementation.
@immutable
class PersistentSender implements Sender {
  final Config config;

  const PersistentSender(this.config);

  /// Sends the provided payload as the body of POST request to
  /// the configured endpoint.
  @override
  Future<bool> send(JsonMap payload) async => sendString(jsonEncode(payload));

  @override
  Future<bool> sendString(String payload) async {
    try {
      Rollbar.process(
          record: PayloadRecord(
              accessToken: config.accessToken,
              endpoint: config.endpoint,
              config: jsonEncode(config.toMap()),
              payload: payload,
              timestamp: DateTime.now().toUtc()));

      return true;
    } catch (error, stackTrace) {
      log('Error persisting payload: $error. Stack trace: $stackTrace');
      return false;
    }
  }
}
