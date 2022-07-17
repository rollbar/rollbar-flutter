import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rollbar_dart/rollbar_dart.dart';
import 'package:rollbar_dart/src/ext/identifiable.dart';

import '../ext/collections.dart';

@sealed
@immutable
class PayloadRecord implements IdentifiableById {
  final DateTime timestamp;
  final String configJson;
  final String payloadJson;
  final Destination destination;

  /// This Record id.
  ///
  /// Computed from the timestamp. Stable.
  @override
  int get id {
    final x = timestamp.millisecondsSinceEpoch;
    return (x ^ (x >> 30)) & 0x3FFFFFFF;
  }

  const PayloadRecord({
    required this.timestamp,
    required this.configJson,
    required this.payloadJson,
    required this.destination,
  });

  PayloadRecord copyWith({
    DateTime? timestamp,
    String? configJson,
    String? payloadJson,
    Destination? destination,
  }) =>
      PayloadRecord(
          timestamp: timestamp ?? this.timestamp,
          configJson: configJson ?? this.configJson,
          payloadJson: payloadJson ?? this.payloadJson,
          destination: destination ?? this.destination);

  JsonMap toMap() => {
        'timestamp': timestamp.millisecondsSinceEpoch,
        'configJson': configJson,
        'payloadJson': payloadJson,
        'destination': destination.toMap()
      };

  factory PayloadRecord.fromMap(JsonMap map) => PayloadRecord(
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      configJson: map['configJson'] ?? '',
      payloadJson: map['payloadJson'] ?? '',
      destination: Destination.fromMap(map['destination']));

  String toJson() => jsonEncode(toMap());

  factory PayloadRecord.fromJson(String source) =>
      PayloadRecord.fromMap(jsonDecode(source));

  @override
  String toString() => 'PayloadRecord('
      'timestamp: $timestamp, '
      'configJson: $configJson, '
      'payloadJson: $payloadJson, '
      'destination: $destination)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayloadRecord &&
          other.timestamp == timestamp &&
          other.configJson == configJson &&
          other.payloadJson == payloadJson);

  @override
  int get hashCode =>
      Object.hash(timestamp, configJson, payloadJson, destination);
}
