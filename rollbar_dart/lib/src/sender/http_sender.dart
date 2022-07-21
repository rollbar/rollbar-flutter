import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import '../ext/collections.dart';
import '../api/response.dart';
import '../logging.dart';
import 'sender.dart';

typedef HttpHeaders = Map<String, String>;

/// HTTP [Sender] implementation.
@sealed
@immutable
class HttpSender implements Sender {
  final Uri endpoint;
  final HttpHeaders headers;

  HttpSender({required String endpoint, required String accessToken})
      : endpoint = Uri.parse(endpoint),
        headers = {
          'User-Agent': 'rollbar-dart',
          'Content-Type': 'application/json',
          'X-Rollbar-Access-Token': accessToken,
        };

  /// Sends the provided payload as the body of POST request to the configured
  /// endpoint.
  @override
  Future<bool> send(JsonMap payload) async => sendString(jsonEncode(payload));

  @override
  Future<bool> sendString(String payload) async {
    try {
      final response = await http
          .post(endpoint, headers: headers, body: payload)
          .then(Response.from);

      if (response.isError) {
        throw HttpException(
          '${response.error}: ${response.message}',
          uri: endpoint,
        );
      }

      return true;
    } catch (error, stackTrace) {
      err('Error posting payload', error, stackTrace);
      return false;
    }
  }
}
