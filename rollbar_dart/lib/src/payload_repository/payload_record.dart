import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rollbar_dart/src/ext/identifiable.dart';

import '../ext/identifiable.dart';
import '../ext/collections.dart';
import '../ext/object.dart';
import 'destination.dart';

@sealed
@immutable
class PayloadRecord implements Identifiable {
  @override
  final UUID id;
  final DateTime timestamp;
  final String configJson;
  final String payloadJson;
  final Destination destination;

  PayloadRecord({
    UUID? id,
    required this.timestamp,
    required this.configJson,
    required this.payloadJson,
    required this.destination,
  }) : id = id ?? uuidGen.v4obj();

  PayloadRecord copyWith({
    UUID? id,
    DateTime? timestamp,
    String? configJson,
    String? payloadJson,
    Destination? destination,
  }) =>
      PayloadRecord(
          id: id ?? this.id,
          timestamp: timestamp ?? this.timestamp,
          configJson: configJson ?? this.configJson,
          payloadJson: payloadJson ?? this.payloadJson,
          destination: destination ?? this.destination);

  factory PayloadRecord.fromMap(JsonMap map) => PayloadRecord(
      id: UUID.new(map.id),
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(map.timestamp, isUtc: true),
      configJson: map.config,
      payloadJson: map.payload,
      destination: Destination.fromMap(map.destination));

  factory PayloadRecord.fromJson(String source) =>
      PayloadRecord.fromMap(jsonDecode(source));

  JsonMap toMap() => {
        'id': id.uuid,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'configJson': configJson,
        'payloadJson': payloadJson,
        'destination': destination.toMap()
      };

  String toJson() => jsonEncode(toMap());

  @override
  String toString() => 'PayloadRecord('
      'id: ${id.uuid}'
      'timestamp: $timestamp, '
      'configJson: $configJson, '
      'payloadJson: $payloadJson, '
      'destination: $destination)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayloadRecord &&
          other.id == id &&
          other.timestamp == timestamp &&
          other.configJson == configJson &&
          other.payloadJson == payloadJson);

  @override
  int get hashCode =>
      Object.hash(id, timestamp, configJson, payloadJson, destination);
}

extension _Attributes on JsonMap {
  String get id => this['id'];
  int get timestamp => this['timestamp'];
  String get config => this['configJson'];
  String get payload => this['payloadJson'];
  JsonMap get destination => this['destination'];
}
