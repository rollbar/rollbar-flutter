import 'dart:convert';

class Destination {
  final int? id;
  final String endpoint;
  final String accessToken;
  Destination({
    required this.id,
    required this.endpoint,
    required this.accessToken,
  });

  Destination copyWith({
    int? id,
    String? endpoint,
    String? accessToken,
  }) {
    return Destination(
      id: id ?? this.id,
      endpoint: endpoint ?? this.endpoint,
      accessToken: accessToken ?? this.accessToken,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'endpoint': endpoint,
      'accessToken': accessToken,
    };
  }

  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id']?.toInt() ?? 0,
      endpoint: map['endpoint'] ?? '',
      accessToken: map['accessToken'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Destination.fromJson(String source) =>
      Destination.fromMap(json.decode(source));

  @override
  String toString() =>
      'Destination(id: $id, endpoint: $endpoint, accessToken: $accessToken)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Destination &&
        other.id == id &&
        other.endpoint == endpoint &&
        other.accessToken == accessToken;
  }

  @override
  int get hashCode => id.hashCode ^ endpoint.hashCode ^ accessToken.hashCode;
}
