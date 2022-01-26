import 'dart:convert';

/// Represents the response from the Rollbar API.
class Response {
  final int? err;
  final String? message;
  final Result? result;

  Response({
    this.err,
    this.message,
    this.result,
  });

  bool isError() {
    return err != null && err != 0;
  }

  Response copyWith({
    int? err,
    String? message,
    Result? result,
  }) {
    return Response(
      err: err ?? this.err,
      message: message ?? this.message,
      result: result ?? this.result,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'err': err,
      'message': message,
      'result': result?.toMap(),
    };
  }

  factory Response.fromMap(Map<String, dynamic> map) {
    return Response(
      err: map['err']?.toInt(),
      message: map['message'],
      result: map['result'] != null ? Result.fromMap(map['result']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Response.fromJson(String source) =>
      Response.fromMap(json.decode(source));

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

class Result {
  final String? uuid;

  Result({
    this.uuid,
  });

  Result copyWith({
    String? uuid,
  }) {
    return Result(
      uuid: uuid ?? this.uuid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
    };
  }

  factory Result.fromMap(Map<String, dynamic> map) {
    return Result(
      uuid: map['uuid'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Result.fromJson(String source) => Result.fromMap(json.decode(source));

  @override
  String toString() => 'Result(uuid: $uuid)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Result && other.uuid == uuid;
  }

  @override
  int get hashCode => uuid.hashCode;
}
