import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:rollbar_dart/rollbar_dart.dart';
import 'dart:convert';
import '_internal/module.dart';
import 'api/response.dart';
import 'sender.dart';

/// Persistent [Sender]. Default [Sender] implementation.
class PersistentSender implements Sender {
  final Config _config;
  final Destination _destination;

  PersistentSender({required Config config, required Destination destination})
      : _config = config,
        _destination = destination;

  /// Sends the provided payload as the body of POST request to the configured endpoint.
  @override
  Future<bool> send(Map<String, dynamic>? payload) async {
    if (payload == null) {
      return false;
    }

    return sendString(json.encode(payload));
  }

  @override
  Future<bool> sendString(String payload) async {
    try {
      final PayloadRecord payloadRecord = PayloadRecord.create(
          configJson: json.encode(_config.toJson()),
          payloadJson: payload,
          destination: _destination);
      RollbarInfrastructure.instance.process(record: payloadRecord);
      return true;
    } catch (error, stackTrace) {
      ModuleLogger.moduleLogger
          .info('Error persisting payload: $error. Stack trace: $stackTrace');
      return false;
    }
  }
}
