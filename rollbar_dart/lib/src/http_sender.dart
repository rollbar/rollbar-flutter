import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '_internal/module.dart';
import 'api/response.dart';
import 'sender.dart';

/// HTTP [Sender] implementation.
class HttpSender implements Sender {
  final String _endpoint;
  final Map<String, String> _headers;

  HttpSender({required String endpoint, required String accessToken})
      : _endpoint = endpoint,
        _headers = <String, String>{
          'User-Agent': 'rollbar-dart',
          'Content-Type': 'application/json',
          'X-Rollbar-Access-Token': accessToken,
        };

  /// Sends the provided payload as the body of POST request to the configured endpoint.
  @override
  Future<bool> send(Map<String, dynamic>? payload) async {
    if (payload == null) {
      return false;
    }

    var requestBody = json.encode(payload);
    return sendString(requestBody);
  }

  @override
  Future<bool> sendString(String payload) async {
    try {
      var response = await http.post(Uri.parse(_endpoint),
          headers: _headers, body: payload);
      return !(await toRollbarResponse(response)).isError();
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

Future<Response> toRollbarResponse(http.Response response) async {
  Map data = json.decode((response).body);

  var result = Response.fromMap(data as Map<String, dynamic>);
  return result;
}
