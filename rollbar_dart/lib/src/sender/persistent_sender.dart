import 'dart:convert';
import 'dart:developer';

import 'package:meta/meta.dart';

import '../ext/collections.dart';
import '../../rollbar.dart';

@internal
Sender persistentSender(Config config) => PersistentSender(
      config: config,
      destination: Destination(
        endpoint: config.endpoint,
        accessToken: config.accessToken,
      ),
    );

/// Persistent [Sender]. Default [Sender] implementation.
@immutable
class PersistentSender implements Sender {
  final Config _config;
  final Destination _destination;

  const PersistentSender({
    required Config config,
    required Destination destination,
  })  : _config = config,
        _destination = destination;

  /// Sends the provided payload as the body of POST request to
  /// the configured endpoint.
  @override
  Future<bool> send(JsonMap payload) async => sendString(jsonEncode(payload));

  @override
  Future<bool> sendString(String payload) async {
    try {
      Rollbar.infrastructure.process(
          record: PayloadRecord.create(
              configJson: jsonEncode(_config.toMap()),
              payloadJson: payload,
              destination: _destination));

      return true;
    } catch (error, stackTrace) {
      log('Error persisting payload: $error. Stack trace: $stackTrace');
      return false;
    }
  }
}
