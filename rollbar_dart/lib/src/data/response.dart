import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:rollbar_common/rollbar_common.dart';

@sealed
@immutable
class ResponseError extends Error {
  final int code;
  final String message;

  ResponseError(this.code, this.message);

  @override
  String toString() => '$code $message';
}

/// Represents the response from the Rollbar API.
///
/// Rollbar will respond with either an error [message] xor a [UUID].
extension APIResponse on http.Response {
  Result<UUID, ResponseError> get result => //
      status == HttpStatus.success
          ? Success(body.uuid)
          : Failure(ResponseError(
              body.error ?? statusCode,
              body.reason ?? reasonPhrase ?? status.name,
            ));
}

extension _Attributes on String {
  JsonMap get body {
    try {
      return jsonDecode(this);
    } catch (_) {
      return {};
    }
  }

  int? get error => body['err'];
  String? get reason => body['message'];
  UUID get uuid => (body['result']['uuid'] as String?)?.toUUID() ?? nilUUID;
}
