import 'dart:convert';

class PayloadRecord {
  final int? id;
  final DateTime timestamp;
  final String configJson;
  final String payloadJson;
  final int destinationID;
  PayloadRecord({
    required this.id,
    required this.timestamp,
    required this.configJson,
    required this.payloadJson,
    required this.destinationID,
  });

  PayloadRecord copyWith({
    int? id,
    DateTime? timestamp,
    String? configJson,
    String? payloadJson,
    int? destinationID,
  }) {
    return PayloadRecord(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      configJson: configJson ?? this.configJson,
      payloadJson: payloadJson ?? this.payloadJson,
      destinationID: destinationID ?? this.destinationID,
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
