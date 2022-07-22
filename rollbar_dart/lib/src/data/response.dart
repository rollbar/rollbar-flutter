import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:rollbar_common/rollbar_common.dart';

/// Represents the response from the Rollbar API.
///
/// Rollbar will respond with either an error [message] xor a [Result].
///
/// [todo] if we ever drop support for Dart <2.17.0, turn this into an
/// [Either monad](https://hackage.haskell.org/package/base-4.16.2.0/docs/Data-Either.html)
/// [Result](https://doc.rust-lang.org/std/result/)
@sealed
@immutable
class Response {
  final int error;
  final String? message;
  final Result? result;

  const Response({
    required this.error,
    this.message,
    this.result,
  });

  bool get isError => error != 0;

  Response copyWith({
    int? error,
    String? message,
    Result? result,
  }) =>
      Response(
          error: error ?? this.error,
          message: message ?? this.message,
          result: result ?? this.result);

  JsonMap toMap() => {
        'err': error,
        'message': message,
        'result': result?.toMap(),
      };

  factory Response.fromMap(JsonMap map) => Response(
        error: map['err']?.toInt() ?? 0,
        message: map['message'],
        result: (map['result'] as JsonMap?).map(Result.fromMap),
      );

  factory Response.from(http.Response response) =>
      Response.fromMap(jsonDecode(response.body));

  @override
  String toString() =>
      'Response(err: $error, message: $message, result: $result)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Response &&
          other.error == error &&
          other.message == message &&
          other.result == result);

  @override
  int get hashCode => error.hashCode ^ message.hashCode ^ result.hashCode;
}

@sealed
@immutable
class Result {
  final String uuid;

  const Result({required this.uuid});

  Result copyWith({String? uuid}) => Result(uuid: uuid ?? this.uuid);

  factory Result.fromMap(JsonMap map) => Result(uuid: map['uuid']);

  JsonMap toMap() => {'uuid': uuid};

  @override
  String toString() => 'Result(uuid: $uuid)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Result && other.uuid == uuid);

  @override
  int get hashCode => uuid.hashCode;
}
