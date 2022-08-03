import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:rollbar_common/rollbar_common.dart';

import '../data/response.dart';
import 'sender.dart';

/// HTTP [Sender] implementation.
@sealed
@immutable
@internal
class HttpSender implements Sender {
  final Uri _endpoint;
  final HttpHeaders _headers;

  HttpSender({required String accessToken, required String endpoint})
      : _endpoint = Uri.parse(endpoint),
        _headers = {
          'User-Agent': 'rollbar-dart',
          'Content-Type': 'application/json',
          'X-Rollbar-Access-Token': accessToken,
        };

  static Future<bool> sendRecord(PayloadRecord record) async =>
      await HttpSender(
        endpoint: record.endpoint,
        accessToken: record.accessToken,
      ).sendString(record.payload);

  /// Sends the provided payload as the body of POST request to the configured
  /// endpoint.
  @override
  Future<bool> send(JsonMap payload) async => sendString(jsonEncode(payload));

  @override
  Future<bool> sendString(String payload) async {
    try {
      final response = await http
          .post(_endpoint, headers: _headers, body: payload)
          .then(Response.from);

      if (response.isError) {
        throw HttpException(
          '${response.error}: ${response.message}',
          uri: _endpoint,
        );
      }

      return true;
    } catch (error, stackTrace) {
      log('Exception sending payload',
          time: DateTime.now(),
          level: Level.error.value,
          name: runtimeType.toString(),
          error: error,
          stackTrace: stackTrace);

      return false;
    }
  }
}
