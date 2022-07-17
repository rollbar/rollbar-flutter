import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rollbar_dart/src/ext/identifiable.dart';

import '../ext/collections.dart';

@sealed
@immutable
class Destination implements IdentifiableById {
  final String endpoint;
  final String accessToken;

  /// This Destination id.
  ///
  /// Computed from the [endpoint] and [accessToken] hashCodes which are
  /// stable between executions.
  @override
  int get id => endpoint.hashCode ^ accessToken.hashCode;

  const Destination({
    required this.endpoint,
    required this.accessToken,
  });

  Destination copyWith({
    String? endpoint,
    String? accessToken,
  }) =>
      Destination(
          endpoint: endpoint ?? this.endpoint,
          accessToken: accessToken ?? this.accessToken);

  JsonMap toMap() => {
        'endpoint': endpoint,
        'accessToken': accessToken,
      };

  factory Destination.fromMap(JsonMap map) => Destination(
        endpoint: map['accessToken'],
        accessToken: map['accessToken'],
      );

  String toJson() => jsonEncode(toMap());

  factory Destination.fromJson(String json) =>
      Destination.fromMap(jsonDecode(json));

  @override
  String toString() =>
      'Destination(endpoint: $endpoint, accessToken: $accessToken)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Destination &&
          other.endpoint == endpoint &&
          other.accessToken == accessToken);

  @override
  int get hashCode => Object.hash(endpoint, accessToken);
}
