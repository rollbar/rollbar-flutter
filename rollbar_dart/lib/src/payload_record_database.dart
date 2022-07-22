import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:sqlite3/sqlite3.dart';

import 'ext/object.dart';
import 'ext/database.dart';
import 'ext/identifiable.dart';

import 'data/payload_record.dart';

/// A collection of [PayloadRecord] that leverages the `sqlite3` library in
/// which each record can occur only once.
///
/// The [Database] has two modes, persistent and in-memory.
///
/// A persistent [Database] is a _shared_ database that will store all its
/// records on the _same_ [Database] file.
///
/// An in-memory [Database] works on its own independent [Database] but it
/// won't persist multiple library runs.
///
/// Access, store or remove [PayloadRecord] objects as if this were any given
/// [Set], all common [Set] rules apply.
///
/// [todo] Turning this into a generic `Database<T>` that implements `Set<T>`
/// should allow us generalize the `Database` over `T`. `T` should conform
/// to some `Recordable` interface that makes it suitable to be stored as a
/// record.
@sealed
@immutable
class PayloadRecordDatabase
    with SetMixin<PayloadRecord>
    implements Set<PayloadRecord> {
  final Database database;

  PayloadRecordDatabase({bool isPersistent = false})
      : database = isPersistent
            ? sqlite3.open('rollbar_payloads.db')
            : sqlite3.openInMemory() {
    database.execute(_SQL.createTable);
  }

  @override
  Iterator<PayloadRecord> get iterator =>
      database.select(_SQL.selectAll).map(PayloadRecord.fromMap).iterator;

  @override
  int get length => database.select(_SQL.selectCountAll).intValue;

  @override
  bool get isEmpty => length == 0;

  PayloadRecord? record({required UUID id}) => database
      .select(_SQL.select, [id.toBytes()])
      .trySingle
      .map(PayloadRecord.fromMap);

  @override
  PayloadRecord? lookup(Object? element) {
    if (element is! PayloadRecord) return null;
    return record(id: element.id);
  }

  @override
  bool contains(Object? element) {
    if (element is! PayloadRecord) return false;
    return database.select(_SQL.selectExists, [element.id.toBytes()]).boolValue;
  }

  @override
  bool add(Object? value) {
    if (value is! PayloadRecord || contains(value)) return false;
    database.execute(_SQL.insert, value.values);
    return true;
  }

  @override
  bool remove(Object? value) {
    if (value is! PayloadRecord || !contains(value)) return false;
    database.execute(_SQL.delete, [value.id.toBytes()]);
    return true;
  }

  void removeOlderThan(DateTime date) =>
      database.execute(_SQL.deleteOlderThan, [date.microsecondsSinceEpoch]);

  @override
  Set<PayloadRecord> toSet() =>
      database.select(_SQL.selectAll).map(PayloadRecord.fromMap).toSet();
}

extension _ListOfValues on PayloadRecord {
  List get values => [
        id.toBytes(),
        accessToken,
        endpoint,
        config,
        payload,
        timestamp.microsecondsSinceEpoch
      ];
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
