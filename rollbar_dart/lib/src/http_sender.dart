import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sender.dart';
import 'api/response.dart';

/// Default HTTP [Sender] implementation.
class HttpSender implements Sender {
  final String _accessToken;
  final String _endpoint;

  HttpSender(this._endpoint, this._accessToken);

  /// Sends the provided payload as the body of POST request to the configured endpoint.
  @override
  Future<Response> send(Map<String, dynamic> payload) async {
    final headers = <String, String>{
      'User-Agent': 'rollbar-dart',
      'Content-Type': 'application/json',
      'X-Rollbar-Access-Token': _accessToken,
    };

    var requestBody = json.encode(payload);

    var response =
        http.post(Uri.parse(_endpoint), headers: headers, body: requestBody);

    return toRollbarResponse(response);
  }
}

Future<Response> toRollbarResponse(Future<http.Response> response) async {
  Map data = json.decode((await response).body);
  var result = Response();
  if (data.containsKey('err')) {
    result.err = data['err'].toInt();
  }
  if (data.containsKey('message')) {
    result.message = data['message'].toString();
  }
  if (data.containsKey('result')) {
    if (data['result'].containsKey('uuid')) {
      result.result = Result()..uuid = data['result']['uuid'].toString();
    }
  }

  return result;
}
