import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import '../ext/collections.dart';
import '../api/response.dart';
import '../logging.dart';
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
  Future<bool> send(JsonMap payload) async => sendString(jsonEncode(payload));

  @override
  Future<bool> sendString(String payload) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: _headers,
        body: payload,
      );

      return !Response.from(response).isError;
    } catch (error, stackTrace) {
      err('Error posting payload', error, stackTrace);
      return false;
    }
  }
}
