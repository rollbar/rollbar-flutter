import 'dart:convert';

import 'package:meta/meta.dart';

import '../ext/identifiable.dart';
import '../ext/collections.dart';

@sealed
@immutable
class Destination implements Identifiable {
  @override
  final UUID id;
  final String endpoint;
  final String accessToken;

  Destination({
    UUID? id,
    required this.endpoint,
    required this.accessToken,
  }) : id = id ?? uuidGen.v4obj();

  Destination copyWith({
    UUID? id,
    String? endpoint,
    String? accessToken,
  }) =>
      Destination(
          id: id ?? this.id,
          endpoint: endpoint ?? this.endpoint,
          accessToken: accessToken ?? this.accessToken);

  factory Destination.fromMap(JsonMap map) => Destination(
        id: map['id'].map(UUID.new),
        endpoint: map['endpoint'],
        accessToken: map['accessToken'],
      );

  factory Destination.fromJson(String json) =>
      Destination.fromMap(jsonDecode(json));

  JsonMap toMap() => {
        'id': id.uuid,
        'endpoint': endpoint,
        'accessToken': accessToken,
      };

  String toJson() => jsonEncode(toMap());

  @override
  String toString() => 'Destination('
      'id: ${id.uuid}, '
      'endpoint: $endpoint, '
      'accessToken: $accessToken)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Destination &&
          other.id == id &&
          other.endpoint == endpoint &&
          other.accessToken == accessToken);

  @override
  int get hashCode => Object.hash(id, endpoint, accessToken);
}
