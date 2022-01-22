import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '_internal/module.dart';
import 'api/response.dart';
import 'sender.dart';

/// Default HTTP [Sender] implementation.
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
  Future<Response?> send(Map<String, dynamic>? payload) async {
    if (payload == null) {
      return null;
    }

    var requestBody = json.encode(payload);
    return sendString(requestBody);
  }

  @override
  Future<Response?> sendString(String payload) async {
    try {
      var response = await http.post(Uri.parse(_endpoint),
          headers: _headers, body: payload);
      return toRollbarResponse(response);
    } on SocketException catch (_) {
      ModuleLogger.moduleLogger
          .info('SocketException while posting payload: $_');
      return null;
    } catch (error, stackTrace) {
      ModuleLogger.moduleLogger
          .info('Error posting payload: $error. Stack trace: $stackTrace');
      return null;
    }
  }
}

Future<Response> toRollbarResponse(http.Response response) async {
  Map data = json.decode((response).body);

  var result = Response.fromMap(data as Map<String, dynamic>);
  // if (data.containsKey('err')) {
  //   result.err = data['err'].toInt();
  // }
  // if (data.containsKey('message')) {
  //   result.message = data['message'].toString();
  // }
  // if (data.containsKey('result')) {
  //   if (data['result'].containsKey('uuid')) {
  //     result.result = Result()..uuid = data['result']['uuid'].toString();
  //   }
  // }

  return result;
}
