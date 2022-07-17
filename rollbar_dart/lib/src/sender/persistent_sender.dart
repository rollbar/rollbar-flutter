import 'dart:convert';
import 'dart:developer';

import 'package:meta/meta.dart';

import '../ext/collections.dart';
import '../../rollbar.dart';

/// Persistent [Sender]. Default [Sender] implementation.
@immutable
class PersistentSender implements Sender {
  final Config config;
  late final Destination destination;

  PersistentSender(this.config)
      : destination = Destination(
          endpoint: config.endpoint,
          accessToken: config.accessToken,
        );

  /// Sends the provided payload as the body of POST request to
  /// the configured endpoint.
  @override
  Future<bool> send(JsonMap payload) async => sendString(jsonEncode(payload));

  @override
  Future<bool> sendString(String payload) async {
    try {
      Rollbar.process(
          record: PayloadRecord(
              configJson: jsonEncode(config.toMap()),
              payloadJson: payload,
              destination: destination,
              timestamp: DateTime.now().toUtc()));

      return true;
    } catch (error, stackTrace) {
      log('Error persisting payload: $error. Stack trace: $stackTrace');
      return false;
    }
  }
}
