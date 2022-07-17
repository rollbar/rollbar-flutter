import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import '../ext/object.dart';
import '../ext/collections.dart';

/// Represents the response from the Rollbar API.
@sealed
@immutable
class Response {
  final int? err;
  final String? message;
  final Result? result;

  Response({
    this.err,
    this.message,
    this.result,
  });

  bool get isError => err != null && err != 0;

  Response copyWith({int? err, String? message, Result? result}) => Response(
        err: err ?? this.err,
        message: message ?? this.message,
        result: result ?? this.result,
      );

  JsonMap toMap() => {
        'err': err,
        'message': message,
        'result': result?.toMap(),
      };

  factory Response.fromMap(JsonMap map) => Response(
        err: map['err']?.toInt(),
        message: map['message'],
        result: (map['result'] as JsonMap?).map(Result.fromMap),
      );

  factory Response.fromJson(String json) => Response.fromMap(jsonDecode(json));

  factory Response.from(http.Response response) =>
      Response.fromMap(jsonDecode(response.body));

  @override
  String toString() =>
      'Response(err: $err, message: $message, result: $result)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Response &&
        other.err == err &&
        other.message == message &&
        other.result == result;
  }

  @override
  int get hashCode => err.hashCode ^ message.hashCode ^ result.hashCode;
}

@sealed
@immutable
class Result {
  final String uuid;

  const Result({required this.uuid});

  Result copyWith({String? uuid}) => Result(uuid: uuid ?? this.uuid);

  factory Result.fromMap(JsonMap map) => Result(uuid: map['uuid']);
  factory Result.fromJson(String source) => Result.fromMap(json.decode(source));

  JsonMap toMap() => {'uuid': uuid};

  @override
  String toString() => 'Result(uuid: $uuid)';

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Result && other.uuid == uuid;
  }

  @override
  int get hashCode => uuid.hashCode;
}
