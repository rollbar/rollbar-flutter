import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:rollbar_common/rollbar_common.dart';

/// Represents the response from the Rollbar API.
///
/// Rollbar will respond with either an error [message] xor a [Result].
@sealed
@immutable
class Response
    with EquatableSerializableMixin
    implements Serializable, Equatable {
  final int error;
  final String? message;
  final UUID? result;

  Response({this.error = 0, this.message, this.result}) {
    if (error == 0 && message == null) {
      ArgumentError.checkNotNull(result, 'result');
    }
  }

  bool get isError => error != 0;

  Response copyWith({int? error, String? message, UUID? result}) => Response(
      error: error ?? this.error,
      message: message ?? this.message,
      result: result ?? this.result);

  @override
  JsonMap toMap() => {
        'err': error,
        'message': message,
        'result': {'uuid': result?.uuid}.compact()
      }.compact();

  factory Response.fromMap(JsonMap map) =>
      Response(error: map.error, message: map.message, result: map.uuid);

  factory Response.from(http.Response response) =>
      Response.fromMap(jsonDecode(response.body));

  @override
  String toString() =>
      'Response(error: $error, message: $message, result: $result)';
}

extension _Attributes on JsonMap {
  int get error => this['err']?.toInt() ?? 0;

  String? get message => this['message'];

  UUID? get uuid {
    final uuid = this['result']?['uuid'] as String?;
    final byteList = uuid
        .map(RegExp(r'\w\w').allMatches)
        ?.map((match) => int.parse(match[0]!, radix: 16))
        .toList();
    return byteList.map(UUID.fromList);
  }
}
