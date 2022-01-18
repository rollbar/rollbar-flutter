import 'dart:convert';

import 'package:meta/meta.dart';

class Destination {
  int? _id;
  late final String endpoint;
  late final String accessToken;

  Destination.create({
    required String endpoint,
    required String accessToken,
  }) : this(endpoint: endpoint, accessToken: accessToken);

  Destination({required this.endpoint, required this.accessToken, int? id})
      : _id = id;

  int? get id => _id;

  @protected
  void assignID(int? value) {
    _id = value;
  }

  Destination copyWith({
    int? id,
    String? endpoint,
    String? accessToken,
  }) {
    return Destination(
      endpoint: endpoint ?? this.endpoint,
      accessToken: accessToken ?? this.accessToken,
      id: id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': _id,
      'endpoint': endpoint,
      'accessToken': accessToken,
    };
  }

  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id']?.toInt(),
      endpoint: map['endpoint'] ?? '',
      accessToken: map['accessToken'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Destination.fromJson(String source) =>
      Destination.fromMap(json.decode(source));

  @override
  String toString() =>
      'Destination(_id: $_id, endpoint: $endpoint, accessToken: $accessToken)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Destination &&
        other._id == _id &&
        other.endpoint == endpoint &&
        other.accessToken == accessToken;
  }

  @override
  int get hashCode => _id.hashCode ^ endpoint.hashCode ^ accessToken.hashCode;
}
