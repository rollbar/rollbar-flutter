import 'dart:io';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import 'ext/module.dart';
import 'ext/collections.dart';
import 'ext/object.dart';
import 'api/response.dart';
import 'sender.dart';

/// HTTP [Sender] implementation.
@sealed
@immutable
class HttpSender implements Sender {
  final String _endpoint;
  final Map<String, String> _headers;

  HttpSender({required String endpoint, required String accessToken})
      : _endpoint = endpoint,
        _headers = {
          'User-Agent': 'rollbar-dart',
          'Content-Type': 'application/json',
          'X-Rollbar-Access-Token': accessToken,
        };

  /// Sends the provided payload as the body of POST request to the configured endpoint.
  @override
  Future<bool> send(JsonMap? payload) async =>
      await payload.map(jsonEncode).map(sendString) ?? false;

  @override
  Future<bool> sendString(String payload) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: _headers,
        body: payload,
      );

      return !Response.from(response).isError;
    } on SocketException catch (_) {
      ModuleLogger.moduleLogger
          .info('SocketException while posting payload: $_');

      return false;
    } catch (error, stackTrace) {
      ModuleLogger.moduleLogger
          .info('Error posting payload: $error. Stack trace: $stackTrace');

      return false;
    }
  }
}
