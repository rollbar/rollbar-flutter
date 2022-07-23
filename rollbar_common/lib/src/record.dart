import 'package:meta/meta.dart';

import 'extension/collection.dart';
import 'identifiable.dart';
import 'persistable.dart';
import 'serializable.dart';

@sealed
@immutable
class Record implements Persistable {
  @override
  final UUID id;
  final DateTime timestamp;
  final String accessToken;
  final String endpoint;
  final String config;
  final String payload;

  @override
  List get values => [
        id.toBytes(),
        accessToken,
        endpoint,
        config,
        payload,
        timestamp.microsecondsSinceEpoch
      ];

  Record({
    UUID? id,
    DateTime? timestamp,
    required this.accessToken,
    required this.endpoint,
    required this.config,
    required this.payload,
  })  : id = id ?? uuidGen.v4obj(),
        timestamp = timestamp ?? DateTime.now().toUtc();

  Record copyWith({
    UUID? id,
    DateTime? timestamp,
    String? accessToken,
    String? endpoint,
    String? config,
    String? payload,
  }) =>
      Record(
          id: id ?? this.id,
          timestamp: timestamp ?? this.timestamp,
          accessToken: accessToken ?? this.accessToken,
          endpoint: endpoint ?? this.endpoint,
          config: config ?? this.config,
          payload: payload ?? this.payload);

  @override
  factory Record.fromMap(JsonMap map) => Record(
      id: map.id,
      timestamp: map.timestamp,
      accessToken: map.accessToken,
      endpoint: map.endpoint,
      config: map.config,
      payload: map.payload);

  @override
  JsonMap toMap() => {
        'id': id.toBytes(),
        'timestamp': timestamp.microsecondsSinceEpoch,
        'accessToken': accessToken,
        'endpoint': endpoint,
        'config': config,
        'payload': payload,
      };

  @override
  String toString() => 'Record('
      'id: ${id.uuid}, '
      'timestamp: $timestamp, '
      'accessToken: $accessToken, '
      'endpoint: $endpoint, '
      'config: $config, '
      'payload: $payload)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Record &&
          other.id == id &&
          other.timestamp == timestamp &&
          other.accessToken == accessToken &&
          other.endpoint == endpoint &&
          other.config == config &&
          other.payload == payload);

  @override
  int get hashCode =>
      Object.hash(id, timestamp, accessToken, endpoint, config, payload);
}

@sealed
class SerializableRecord implements SerializableFor {
  const SerializableRecord();

  @override
  Record fromMap(JsonMap map) => Record.fromMap(map);
}

extension RecordAttributes on JsonMap {
  UUID get id => UUID.fromList(this['id'].whereType<int>().toList());
  String get accessToken => this['accessToken'];
  String get endpoint => this['endpoint'];
  String get config => this['config'];
  String get payload => this['payload'];
  DateTime get timestamp =>
      DateTime.fromMicrosecondsSinceEpoch(this['timestamp'], isUtc: true);
}
