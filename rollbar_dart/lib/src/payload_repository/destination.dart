import 'dart:convert';

import 'package:meta/meta.dart';

import '../ext/collections.dart';

@sealed
@immutable
class Destination {
  final int id;
  final String endpoint;
  final String accessToken;

  // Destination.create({
  //   required String endpoint,
  //   required String accessToken,
  // }) : this(endpoint: endpoint, accessToken: accessToken);

  Destination({
    required this.endpoint,
    required this.accessToken,
    required this.id,
  });

  // int? get id => _id;

  // @protected
  // void assignID(int? value) {
  //   _id = value;
  // }

  Destination copyWith({
    int? id,
    String? endpoint,
    String? accessToken,
  }) =>
      Destination(
          endpoint: endpoint ?? this.endpoint,
          accessToken: accessToken ?? this.accessToken,
          id: id ?? this.id);

  JsonMap toMap() => {
        '_id': id,
        'endpoint': endpoint,
        'accessToken': accessToken,
      };

  factory Destination.fromMap(Map<String, dynamic> map) => Destination(
      id: map['id']?.toInt(),
      endpoint: map['endpoint'],
      accessToken: map['accessToken']);

  String toJson() => jsonEncode(toMap());

  factory Destination.fromJson(String json) =>
      Destination.fromMap(jsonDecode(json));

  @override
  String toString() =>
      'Destination(_id: $id, endpoint: $endpoint, accessToken: $accessToken)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Destination &&
          other.id == id &&
          other.endpoint == endpoint &&
          other.accessToken == accessToken);

  @override
  int get hashCode => id.hashCode ^ endpoint.hashCode ^ accessToken.hashCode;
}
