import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rollbar_dart/rollbar_dart.dart';

class PayloadRecord {
  int? _id;
  late final DateTime timestamp;
  late final String configJson;
  late final String payloadJson;

  late final Destination destination;

  PayloadRecord.create(
      {required String configJson,
      required String payloadJson,
      required Destination destination})
      : this(
            timestamp: DateTime.now().toUtc(),
            configJson: configJson,
            payloadJson: payloadJson,
            destination: destination);

  PayloadRecord(
      {required this.timestamp,
      required this.configJson,
      required this.payloadJson,
      required this.destination,
      int? id})
      : _id = id;

  int? get id => _id;

  @protected
  void assignID(int? value) {
    _id = value;
  }

  //int? get destinationID => destination.id;

  PayloadRecord copyWith({
    int? id,
    DateTime? timestamp,
    String? configJson,
    String? payloadJson,
    Destination? destination,
  }) {
    return PayloadRecord(
      timestamp: timestamp ?? this.timestamp,
      configJson: configJson ?? this.configJson,
      payloadJson: payloadJson ?? this.payloadJson,
      destination: destination ?? this.destination,
      id: id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'configJson': configJson,
      'payloadJson': payloadJson,
      'destination': destination.toMap(),
    };
  }

  factory PayloadRecord.fromMap(Map<String, dynamic> map) {
    return PayloadRecord(
      id: map['id']?.toInt(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      configJson: map['configJson'] ?? '',
      payloadJson: map['payloadJson'] ?? '',
      destination: Destination.fromMap(map['destination']),
    );
  }

  String toJson() => json.encode(toMap());

  factory PayloadRecord.fromJson(String source) =>
      PayloadRecord.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PayloadRecord(id: $id, timestamp: $timestamp, configJson: $configJson, payloadJson: $payloadJson, destination: $destination)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PayloadRecord &&
        other.id == id &&
        other.timestamp == timestamp &&
        other.configJson == configJson &&
        other.payloadJson == payloadJson &&
        other.destination.id == destination.id;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        timestamp.hashCode ^
        configJson.hashCode ^
        payloadJson.hashCode ^
        destination.hashCode;
  }
}
