import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rollbar_dart/src/ext/identifiable.dart';

import '../ext/identifiable.dart';
import '../ext/collections.dart';

@sealed
@immutable
class PayloadRecord implements Identifiable {
  @override
  final UUID id;
  final DateTime timestamp;
  final String accessToken;
  final String endpoint;
  final String configJson;
  final String payloadJson;

  PayloadRecord({
    UUID? id,
    required this.timestamp,
    required this.accessToken,
    required this.endpoint,
    required this.configJson,
    required this.payloadJson,
  }) : id = id ?? uuidGen.v4obj();

  PayloadRecord copyWith({
    UUID? id,
    DateTime? timestamp,
    String? accessToken,
    String? endpoint,
    String? configJson,
    String? payloadJson,
  }) =>
      PayloadRecord(
          id: id ?? this.id,
          timestamp: timestamp ?? this.timestamp,
          accessToken: accessToken ?? this.accessToken,
          endpoint: endpoint ?? this.endpoint,
          configJson: configJson ?? this.configJson,
          payloadJson: payloadJson ?? this.payloadJson);

  factory PayloadRecord.fromMap(JsonMap map) => PayloadRecord(
      id: UUID.new(map.id),
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(map.timestamp, isUtc: true),
      accessToken: map.accessToken,
      endpoint: map.endpoint,
      configJson: map.config,
      payloadJson: map.payload);

  factory PayloadRecord.fromJson(String source) =>
      PayloadRecord.fromMap(jsonDecode(source));

  JsonMap toMap() => {
        'id': id.uuid,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'accessToken': accessToken,
        'endpoint': endpoint,
        'configJson': configJson,
        'payloadJson': payloadJson,
      };

  String toJson() => jsonEncode(toMap());

  @override
  String toString() => 'PayloadRecord('
      'id: ${id.uuid}'
      'timestamp: $timestamp, '
      'accessToken: $accessToken, '
      'endpoint: $endpoint, '
      'configJson: $configJson, '
      'payloadJson: $payloadJson)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayloadRecord &&
          other.id == id &&
          other.timestamp == timestamp &&
          other.accessToken == accessToken &&
          other.endpoint == endpoint &&
          other.configJson == configJson &&
          other.payloadJson == payloadJson);

  @override
  int get hashCode => Object.hash(
      id, timestamp, accessToken, endpoint, configJson, payloadJson);
}

extension _Attributes on JsonMap {
  String get id => this['id'];
  int get timestamp => this['timestamp'];
  String get accessToken => this['accessToken'];
  String get endpoint => this['endpoint'];
  String get config => this['configJson'];
  String get payload => this['payloadJson'];
}
