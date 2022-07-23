import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

import '../ext/identifiable.dart';

@sealed
@immutable
class PayloadRecord implements Identifiable {
  @override
  final UUID id;
  final DateTime timestamp;
  final String accessToken;
  final String endpoint;
  final String config;
  final String payload;

  PayloadRecord({
    UUID? id,
    DateTime? timestamp,
    required this.accessToken,
    required this.endpoint,
    required this.config,
    required this.payload,
  })  : id = id ?? uuidGen.v4obj(),
        timestamp = timestamp ?? DateTime.now().toUtc();

  PayloadRecord copyWith({
    UUID? id,
    DateTime? timestamp,
    String? accessToken,
    String? endpoint,
    String? config,
    String? payload,
  }) =>
      PayloadRecord(
          id: id ?? this.id,
          timestamp: timestamp ?? this.timestamp,
          accessToken: accessToken ?? this.accessToken,
          endpoint: endpoint ?? this.endpoint,
          config: config ?? this.config,
          payload: payload ?? this.payload);

  factory PayloadRecord.fromMap(JsonMap map) => PayloadRecord(
      id: map.id,
      timestamp: map.timestamp,
      accessToken: map.accessToken,
      endpoint: map.endpoint,
      config: map.config,
      payload: map.payload);

  JsonMap toMap() => {
        'id': id.toBytes(),
        'timestamp': timestamp.microsecondsSinceEpoch,
        'accessToken': accessToken,
        'endpoint': endpoint,
        'config': config,
        'payload': payload,
      };

  @override
  String toString() => 'PayloadRecord('
      'id: ${id.uuid}, '
      'timestamp: $timestamp, '
      'accessToken: $accessToken, '
      'endpoint: $endpoint, '
      'config: $config, '
      'payload: $payload)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayloadRecord &&
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

extension PayloadRecordAttributes on JsonMap {
  UUID get id => UUID.fromList(this['id'].whereType<int>().toList());
  String get accessToken => this['accessToken'];
  String get endpoint => this['endpoint'];
  String get config => this['config'];
  String get payload => this['payload'];
  DateTime get timestamp =>
      DateTime.fromMicrosecondsSinceEpoch(this['timestamp'], isUtc: true);
}
