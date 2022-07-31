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
class ReadingRecord implements Persistable<UUID> {
  @override
  final UUID id;
  final String reading;
  final DateTime timestamp;

  static Map<String, Datatype> get persistingKeyTypes => {
        'id': Datatype.uuid,
        'reading': Datatype.text,
        'timestamp': Datatype.integer,
      };

  ReadingRecord({
    UUID? id,
    required this.reading,
    DateTime? timestamp,
  })  : id = id ?? uuidGen.v4obj(),
        timestamp = timestamp ?? DateTime.now().toUtc();

  ReadingRecord copyWith({
    UUID? id,
    String? reading,
    DateTime? timestamp,
  }) =>
      ReadingRecord(
          id: id ?? this.id,
          reading: reading ?? this.reading,
          timestamp: timestamp ?? this.timestamp);

  @override
  factory ReadingRecord.fromMap(JsonMap map) => ReadingRecord(
        id: map.id,
        reading: map.reading,
        timestamp: map.timestamp,
      );

  @override
  JsonMap toMap() => {
        'id': id.toBytes(),
        'reading': reading,
        'timestamp': timestamp.microsecondsSinceEpoch,
      };

  /// Compares this [ReadingRecord] to another [ReadingRecord].
  ///
  /// Comparison is timestamp-based.
  ///
  /// If [other] is not a [ReadingRecord] instance, an [ArgumentError] is
  /// thrown.
  ///
  /// Returns a value like a [Comparator] when comparing this to [other]. That
  /// is, it returns a negative integer if this is ordered before [other], a
  /// positive integer if this is ordered after [other], and zero if this and
  /// [other] are ordered together.
  ///
  /// The [other] argument must be a value that is comparable to this object.
  @override
  int compareTo(other) {
    if (other is! ReadingRecord) {
      throw ArgumentError('Cannot compare between different types.', other);
    }

    return timestamp.compareTo(other.timestamp);
  }

  @override
  String toString() => 'Record('
      'id: ${id.uuid}, '
      'reading: $reading, '
      'timestamp: $timestamp)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingRecord &&
          other.id == id &&
          other.reading == reading &&
          other.timestamp == timestamp);

  @override
  int get hashCode => Object.hash(id, reading, timestamp);
}

@sealed
class SerializableReadingRecord implements SerializableFor {
  const SerializableReadingRecord();

  @override
  ReadingRecord fromMap(JsonMap map) => ReadingRecord.fromMap(map);
}

@sealed
class PersistableReadingRecord implements PersistableFor {
  const PersistableReadingRecord();

  @override
  Map<String, Datatype> get persistingKeyTypes =>
      ReadingRecord.persistingKeyTypes;
}

extension ReadingRecordAttributes on JsonMap {
  UUID get id => UUID.fromList(this['id'].whereType<int>().toList());
  String get reading => this['reading'];
  DateTime get timestamp => DateTime.fromMicrosecondsSinceEpoch(
        this['timestamp'],
        isUtc: true,
      );
}
