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
class BreadcrumbRecord implements Persistable<UUID> {
  @override
  final UUID id;
  @override
  final DateTime timestamp;

  final String breadcrumb;

  static Map<String, Datatype> get persistingKeyTypes => {
        'id': Datatype.uuid,
        'breadcrumb': Datatype.text,
        'timestamp': Datatype.integer,
      };

  BreadcrumbRecord({
    UUID? id,
    required this.breadcrumb,
    DateTime? timestamp,
  })  : id = id ?? uuidGen.v4obj(),
        timestamp = timestamp ?? DateTime.now().toUtc();

  BreadcrumbRecord copyWith({
    UUID? id,
    String? breadcrumb,
    DateTime? timestamp,
  }) =>
      BreadcrumbRecord(
          id: id ?? this.id,
          breadcrumb: breadcrumb ?? this.breadcrumb,
          timestamp: timestamp ?? this.timestamp);

  @override
  factory BreadcrumbRecord.fromMap(JsonMap map) => BreadcrumbRecord(
        id: map.id,
        breadcrumb: map.breadcrumb,
        timestamp: map.timestamp,
      );

  @override
  JsonMap toMap() => {
        'id': id.toBytes(),
        'breadcrumb': breadcrumb,
        'timestamp': timestamp.microsecondsSinceEpoch,
      };

  /// Compares this [BreadcrumbRecord] to another [BreadcrumbRecord].
  ///
  /// Comparison is timestamp-based.
  ///
  /// If [other] is not a [BreadcrumbRecord] instance, an [ArgumentError] is
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
    if (other is! BreadcrumbRecord) {
      throw ArgumentError('Cannot compare between different types.', 'other');
    }

    return timestamp.compareTo(other.timestamp);
  }

  @override
  String toString() => 'Record('
      'id: ${id.uuid}, '
      'breadcrumb: $breadcrumb, '
      'timestamp: $timestamp)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BreadcrumbRecord &&
          other.id == id &&
          other.breadcrumb == breadcrumb &&
          other.timestamp == timestamp);

  @override
  int get hashCode => Object.hash(id, breadcrumb, timestamp);
}

@sealed
class SerializableBreadcrumbRecord implements SerializableFor {
  const SerializableBreadcrumbRecord();

  @override
  BreadcrumbRecord fromMap(JsonMap map) => BreadcrumbRecord.fromMap(map);
}

@sealed
class PersistableBreadcrumbRecord implements PersistableFor {
  const PersistableBreadcrumbRecord();

  @override
  Map<String, Datatype> get persistingKeyTypes =>
      BreadcrumbRecord.persistingKeyTypes;
}

extension _KeyValuePaths on JsonMap {
  UUID get id => UUID.fromList(this['id'].whereType<int>().toList());
  String get breadcrumb => this['breadcrumb'];
  DateTime get timestamp => DateTime.fromMicrosecondsSinceEpoch(
        this['timestamp'],
        isUtc: true,
      );
}
