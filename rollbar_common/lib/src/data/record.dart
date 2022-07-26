import 'package:meta/meta.dart';

import '../extension/collection.dart';
import '../identifiable.dart';
import '../persistable.dart';
import '../serializable.dart';

@sealed
@immutable
class Record implements Persistable<UUID> {
  @override
  final UUID id;
  final String accessToken;
  final String endpoint;
  final String config;
  final String payload;
  final DateTime timestamp;

  static Map<String, Datatype> get persistingKeyTypes => {
        'id': Datatype.uuid,
        'accessToken': Datatype.text,
        'endpoint': Datatype.text,
        'config': Datatype.text,
        'payload': Datatype.text,
        'timestamp': Datatype.integer,
      };

  Record({
    UUID? id,
    required this.accessToken,
    required this.endpoint,
    required this.config,
    required this.payload,
    DateTime? timestamp,
  })  : id = id ?? uuidGen.v4obj(),
        timestamp = timestamp ?? DateTime.now().toUtc();

  Record copyWith({
    UUID? id,
    String? accessToken,
    String? endpoint,
    String? config,
    String? payload,
    DateTime? timestamp,
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
      accessToken: map.accessToken,
      endpoint: map.endpoint,
      config: map.config,
      payload: map.payload,
      timestamp: map.timestamp);

  @override
  JsonMap toMap() => {
        'id': id.toBytes(),
        'accessToken': accessToken,
        'endpoint': endpoint,
        'config': config,
        'payload': payload,
        'timestamp': timestamp.microsecondsSinceEpoch,
      };

  @override
  String toString() => 'Record('
      'id: ${id.uuid}, '
      'accessToken: $accessToken, '
      'endpoint: $endpoint, '
      'config: $config, '
      'payload: $payload, '
      'timestamp: $timestamp)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Record &&
          other.id == id &&
          other.accessToken == accessToken &&
          other.endpoint == endpoint &&
          other.config == config &&
          other.payload == payload &&
          other.timestamp == timestamp);

  @override
  int get hashCode =>
      Object.hash(id, accessToken, endpoint, config, payload, timestamp);
}

@sealed
class SerializableRecord implements SerializableFor {
  const SerializableRecord();

  @override
  Record fromMap(JsonMap map) => Record.fromMap(map);
}

@sealed
class PersistableRecord implements PersistableFor {
  const PersistableRecord();

  @override
  Map<String, Datatype> get persistingKeyTypes => Record.persistingKeyTypes;
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
