import 'dart:convert';
import 'dart:developer';
import '../ext/object.dart';
import '../ext/collections.dart';
import '../../rollbar.dart';

/// Persistent [Sender]. Default [Sender] implementation.
class PersistentSender implements Sender {
  final Config _config;
  final Destination _destination;

  PersistentSender({
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
      final config = _config.toMap()
        ..remove('transformer')
        ..remove('sender');

      final record = PayloadRecord.create(
        configJson: jsonEncode(config),
        payloadJson: payload,
        destination: _destination,
      );

      RollbarInfrastructure.process(record: record);

      return true;
    } catch (error, stackTrace) {
      log('Error persisting payload: $error. Stack trace: $stackTrace');
      return false;
    }
  }
}
