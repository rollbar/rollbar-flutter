import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:sqlite3/sqlite3.dart';

import 'extension/object.dart';
import 'extension/collection.dart';
import 'identifiable.dart';
import 'serializable.dart';
import 'persistable.dart';
import 'extension/database.dart';

@sealed
@immutable
class TableSet<E extends Persistable<UUID>> with SetMixin<E> implements Set<E> {
  final Database database;

  TableSet({bool isPersistent = false})
      : database = isPersistent
            ? sqlite3.open('rollbar_payloads.db')
            : sqlite3.openInMemory() {
    database.execute(_SQL.createTable);
  }

  @override
  Iterator<E> get iterator =>
      database.select(_SQL.selectAll).map(deserialize).iterator;

  @override
  int get length => database.select(_SQL.selectCountAll).intValue;

  @override
  bool get isEmpty => length == 0;

  E? record({required UUID id}) => database
      .select(_SQL.select, [id.toBytes()])
      .trySingle
      .map((result) => Serializable.of<E>().fromMap(result) as E);

  @override
  E? lookup(Object? element) {
    if (element is! E) return null;
    return record(id: element.id);
  }

  @override
  bool contains(Object? element) {
    if (element is! E) return false;
    return database.select(_SQL.selectExists, [element.id.toBytes()]).boolValue;
  }

  @override
  bool add(Object? value) {
    if (value is! E || contains(value)) return false;
    database.execute(_SQL.insert, value.values);
    return true;
  }

  @override
  bool remove(Object? value) {
    if (value is! E || !contains(value)) return false;
    database.execute(_SQL.delete, [value.id.toBytes()]);
    return true;
  }

  void removeOlderThan(DateTime date) =>
      database.execute(_SQL.deleteOlderThan, [date.microsecondsSinceEpoch]);

  @override
  Set<E> toSet() => database.select(_SQL.selectAll).map(deserialize).toSet();

  /// Creates a **new** [Database] which contains all the records of this set
  /// and [other].
  ///
  /// That is, the returned [Database] contains all the records of this
  /// [Database] and all the elements of [other].
  @override
  TableSet<E> union(Set<E> other) {
    return TableSet()
      ..addAll(this)
      ..addAll(other);
  }

  /// Creates a **new** [Database] which is the intersection between this
  /// [Database] and [other].
  ///
  /// That is, the returned [Database] contains all the records of this
  /// [Database] that are _also_ elements of [other] according to
  /// `other.contains`.
  @override
  TableSet<E> intersection(Set<Object?> other) {
    final result = TableSet<E>()..addAll(this);
    result.where(not(other.contains)).forEach(result.remove);
    return result;
  }

  /// Creates a **new** [Database] with the records of this [Database] that
  /// are not in [other].
  ///
  /// That is, the returned [Database] contains all the records of this
  /// [Database] that are not elements of [other] according to
  /// `other.contains`.
  @override
  TableSet<E> difference(Set<Object?> other) {
    final result = TableSet<E>()..addAll(this);
    result.where(other.contains).forEach(result.remove);
    return result;
  }

  @internal
  @protected
  E deserialize(JsonMap map) => Serializable.of<E>().fromMap(map) as E;
}

class _SQL {
  static const String table = 'payload_records';
  static const String id = 'id';
  static const String token = 'accessToken';
  static const String endpoint = 'endpoint';
  static const String config = 'config';
  static const String payload = 'payload';
  static const String timestamp = 'timestamp';

  static const String createTable = '''
    CREATE TABLE IF NOT EXISTS $table (
      $id	BINARY(16) NOT NULL PRIMARY KEY,
      $token TEXT NOT NULL,
      $endpoint TEXT NOT NULL,
      $config TEXT NOT NULL,
      $payload TEXT NOT NULL,
      $timestamp INTEGER NOT NULL)
    ''';

  static const String select = '''
    SELECT $id, $token, $endpoint, $config, $payload, $timestamp
    FROM $table
    WHERE $id = ?
    ''';

  static const String selectAll = '''
    SELECT *
    FROM $table
    ''';

  static const String selectCountAll = '''
    SELECT COUNT(*)
    FROM $table
    ''';

  static const String selectExists = '''
    SELECT EXISTS(
      SELECT 1
      FROM $table
      WHERE $id = ?)
    ''';

  static const String insert = '''
    INSERT INTO $table ($id, $token, $endpoint, $config, $payload, $timestamp)
    VALUES (?, ?, ?, ?, ?, ?)
    ''';

  static const String delete = '''
    DELETE FROM $table
    WHERE $id = ?
    ''';

  static const String deleteOlderThan = '''
    DELETE FROM $table
    WHERE $timestamp <= ?
    ''';
}
