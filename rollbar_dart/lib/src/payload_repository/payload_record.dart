import 'dart:convert';

import 'package:meta/meta.dart';

class PayloadRecord {
  int? _id;
  late final DateTime timestamp;
  late final String configJson;
  late final String payloadJson;
  late final int destinationID;

  PayloadRecord.create(
      {required String configJson,
      required String payloadJson,
      required int destinationID})
      : this(
            timestamp: DateTime.now().toUtc(),
            configJson: configJson,
            payloadJson: payloadJson,
            destinationID: destinationID,
            id: null);

  PayloadRecord(
      {required DateTime timestamp,
      required String configJson,
      required String payloadJson,
      required int destinationID,
      required int? id}) {
    this.timestamp = timestamp;
    this.configJson = configJson;
    this.payloadJson = payloadJson;
    this.destinationID = destinationID;
    _id = id;
  }

  int? get id => _id;

  @protected
  void assignID(int? value) {
    _id = value;
  }

  PayloadRecord copyWith({
    int? id,
    DateTime? timestamp,
    String? configJson,
    String? payloadJson,
    int? destinationID,
  }) {
    return PayloadRecord(
      timestamp: timestamp ?? this.timestamp,
      configJson: configJson ?? this.configJson,
      payloadJson: payloadJson ?? this.payloadJson,
      destinationID: destinationID ?? this.destinationID,
      id: id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'configJson': configJson,
      'payloadJson': payloadJson,
      'destinationID': destinationID,
    };
  }

  factory PayloadRecord.fromMap(Map<String, dynamic> map) {
    return PayloadRecord(
      id: map['id']?.toInt(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      configJson: map['configJson'] ?? '',
      payloadJson: map['payloadJson'] ?? '',
      destinationID: map['destinationID']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory PayloadRecord.fromJson(String source) =>
      PayloadRecord.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PayloadRecord(id: $id, timestamp: $timestamp, configJson: $configJson, payloadJson: $payloadJson, destinationID: $destinationID)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PayloadRecord &&
        other.id == id &&
        other.timestamp == timestamp &&
        other.configJson == configJson &&
        other.payloadJson == payloadJson &&
        other.destinationID == destinationID;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        timestamp.hashCode ^
        configJson.hashCode ^
        payloadJson.hashCode ^
        destinationID.hashCode;
  }
}
