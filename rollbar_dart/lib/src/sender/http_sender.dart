import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';
import 'package:rollbar_dart/rollbar_dart.dart';

import '../data/config.dart';

/// HTTP [Sender] implementation.
@sealed
@immutable
@internal
class HttpSender implements Configurable, Sender {
  @override
  final Config config;
  final HttpHeaders headers;
  final Uri uri;

  HttpSender(this.config)
      : uri = Uri.parse(config.endpoint),
        headers = {
          'User-Agent': 'rollbar-dart',
          'Content-Type': 'application/json',
          'X-Rollbar-Access-Token': config.accessToken,
        };

  /// Sends the provided payload as the body of POST request to the configured
  /// endpoint.
  @override
  Future<bool> send(final JsonMap payload) async =>
      sendString(jsonEncode(payload));

  @override
  Future<bool> sendString(final String payload) async {
    final client = config.httpClient();

    try {
      final response = await client.post(uri, headers: headers, body: payload);

      if (response.status != HttpStatus.success) {
        throw HttpException(
          response.reasonPhrase ?? response.status.name,
          uri: uri,
        );
      }

      return true;
    } catch (error, stackTrace) {
      log('Error sending payload to \'$uri\'',
          name: 'Rollbar.${runtimeType.toString()}',
          time: DateTime.now(),
          level: Level.error.value,
          error: error,
          stackTrace: stackTrace);

      return false;
    } finally {
      client.close();
    }
  }
}
