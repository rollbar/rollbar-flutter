import 'dart:developer' as developer;

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:rollbar_common/rollbar_common.dart';
import 'package:rollbar_dart/rollbar_dart.dart';

import '../data/response.dart';
import '../persistence.dart';
import 'http_sender.dart';

/// A [Sender] that persists payloads and defers its transport in case of
/// client connectivity issues, temporary server errors, or interruptions.
@sealed
@immutable
@internal
class PersistentHttpSender extends HttpSender with Persistence<PayloadRecord> {
  PersistentHttpSender(super.config);

  @override
  Future<bool> sendString(final String payload) async {
    final newRecord = PayloadRecord(
      accessToken: config.accessToken,
      endpoint: config.endpoint,
      payload: payload,
    );

    records.add(newRecord);
    records.where(didExpire).forEach(records.remove);

    if (_State.suspended) return false;

    final httpClient = config.httpClient();

    try {
      for (final record in records) {
        final response = await httpClient.post(
          uri,
          headers: headers,
          body: record.payload,
        );

        if (response.status == HttpStatus.success) {
          records.remove(record);
          continue;
        }

        log(response);
        switch (response.statusCode) {
          case 413: // Payload Too Large
          case 422: // Unprocessable Entity
            records.remove(record);
            break;
          case 429: // Too Many Requests
          case 500: // Internal Server Error
          case 501: // Not Implemented
          case 502: // Bad Gateway
          case 503: // Service Unavailable
          case 504: // Gateway Timeout
            _State.suspend(30.seconds);
            return false;
        }
      }

      return !records.contains(newRecord);
    } on http.ClientException catch (error, stackTrace) {
      log(error, stackTrace);
      return false;
    } finally {
      httpClient.close();
    }
  }

  void log(final Object o, [final StackTrace? stackTrace]) {
    if (o is http.Response) {
      developer.log(
          '\'${o.statusCode} ${o.reasonPhrase}\' sending payload to \'$uri\'',
          name: 'Rollbar.${runtimeType.toString()}',
          time: DateTime.now(),
          level: Level.error.value,
          error: o.result.failure,
          stackTrace: StackTrace.current);
    } else if (o is http.ClientException) {
      developer.log('${o.message} while trying to reach \'${o.uri}\'',
          name: 'Rollbar.${runtimeType.toString()}',
          time: DateTime.now(),
          level: Level.critical.value,
          error: o,
          stackTrace: stackTrace);
    }
  }
}

extension _State on HttpSender {
  static bool _suspended = false;

  static bool get suspended => _suspended;

  static void suspend(final Duration duration) async {
    if (_suspended) return;
    _suspended = true;
    _suspended = await Future.delayed(duration).then((_) => false);
  }
}
