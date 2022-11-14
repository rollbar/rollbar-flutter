import 'package:meta/meta.dart';
import '../../rollbar_common.dart'
    show
        Persistable,
        PersistableFor,
        SerializableFor,
        UUID,
        uuidGen,
        Datatype,
        JsonMap;

@sealed
@immutable
class PayloadRecord implements Persistable<UUID> {
  @override
  final UUID id;
  @override
  final DateTime timestamp;

  final String accessToken;
  final String endpoint;
  final String payload;

  static Map<String, Datatype> get persistingKeyTypes => {
        'id': Datatype.uuid,
        'accessToken': Datatype.text,
        'endpoint': Datatype.text,
        'payload': Datatype.text,
        'timestamp': Datatype.integer,
      };

  PayloadRecord({
    UUID? id,
    required this.accessToken,
    required this.endpoint,
    required this.payload,
    DateTime? timestamp,
  })  : id = id ?? uuidGen.v4obj(),
        timestamp = timestamp ?? DateTime.now().toUtc();

  PayloadRecord copyWith({
    UUID? id,
    String? accessToken,
    String? endpoint,
    String? payload,
    DateTime? timestamp,
  }) =>
      PayloadRecord(
          id: id ?? this.id,
          accessToken: accessToken ?? this.accessToken,
          endpoint: endpoint ?? this.endpoint,
          payload: payload ?? this.payload,
          timestamp: timestamp ?? this.timestamp);

  @override
  factory PayloadRecord.fromMap(JsonMap map) => PayloadRecord(
      id: map.id,
      accessToken: map.accessToken,
      endpoint: map.endpoint,
      payload: map.payload,
      timestamp: map.timestamp);

  @override
  JsonMap toMap() => {
        'id': id.toBytes(),
        'accessToken': accessToken,
        'endpoint': endpoint,
        'payload': payload,
        'timestamp': timestamp.microsecondsSinceEpoch,
      };

  /// Compares this [PayloadRecord] to another [PayloadRecord].
  ///
  /// Comparison is timestamp-based.
  ///
  /// If [other] is not a [PayloadRecord] instance, an [ArgumentError] is
  /// thrown.
  ///
  /// Returns a value like a [Comparator] when comparing this to [other]. That
  /// is, it returns a negative integer if this is ordered before [other], a
  /// positive integer if this is ordered after [other], and zero if this and
  /// [other] are ordered together.
  ///
  /// The [other] argument must be a value that is comparable to this object.
  @override
  int compareTo(Persistable<UUID> other) {
    if (other is! PayloadRecord) {
      throw ArgumentError('Cannot compare between different types.', 'other');
    }

    return timestamp.compareTo(other.timestamp);
  }

  @override
  String toString() => 'Record('
      'id: ${id.uuid}, '
      'accessToken: $accessToken, '
      'endpoint: $endpoint, '
      'payload: $payload, '
      'timestamp: $timestamp)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayloadRecord &&
          other.id == id &&
          other.accessToken == accessToken &&
          other.endpoint == endpoint &&
          other.payload == payload &&
          other.timestamp == timestamp);

  @override
  int get hashCode =>
      Object.hash(id, accessToken, endpoint, payload, timestamp);
}

@sealed
class SerializablePayloadRecord implements SerializableFor {
  const SerializablePayloadRecord();

  @override
  PayloadRecord fromMap(JsonMap map) => PayloadRecord.fromMap(map);
}

@sealed
class PersistablePayloadRecord implements PersistableFor {
  const PersistablePayloadRecord();

  @override
  Map<String, Datatype> get persistingKeyTypes =>
      PayloadRecord.persistingKeyTypes;
}

extension _KeyValuePaths on JsonMap {
  UUID get id => UUID.fromList(this['id'].whereType<int>().toList());
  String get accessToken => this['accessToken'];
  String get endpoint => this['endpoint'];
  String get payload => this['payload'];
  DateTime get timestamp => DateTime.fromMicrosecondsSinceEpoch(
        this['timestamp'],
        isUtc: true,
      );
}
