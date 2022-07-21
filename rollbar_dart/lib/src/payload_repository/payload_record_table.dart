import 'dart:typed_data';
import 'package:meta/meta.dart';
import 'package:sqlite3/sqlite3.dart';

@sealed
class _Column {
  static const String name = 'payload_records';
  static const String id = 'id';
  static const String accessToken = 'access_token';
  static const String endpoint = 'endpoint';
  static const String config = 'config';
  static const String payload = 'payload';
  static const String createdAt = 'created_at_utc_unix_epoch_sec';
}

@internal
extension Accessors on Row {
  Uint8List get id => this[_Column.id];
  String get endpoint => this[_Column.endpoint];
  String get accessToken => this[_Column.accessToken];
  String get config => this[_Column.config];
  String get payload => this[_Column.payload];
  int get timestamp => this[_Column.createdAt];
}

@sealed
@internal
class SQL {
  static const String checkIfTableExists = '''
    SELECT name
    FROM sqlite_master
    WHERE type='table' AND name=?
    ''';

  static const String createPayloadRecordsTable = '''
    CREATE TABLE IF NOT EXISTS "${_Column.name}" (
      "${_Column.id}"	BINARY(16) NOT NULL PRIMARY KEY,
      "${_Column.accessToken}"	TEXT NOT NULL,
      "${_Column.endpoint}"	TEXT NOT NULL,
      "${_Column.config}"	TEXT NOT NULL,
      "${_Column.payload}"	TEXT NOT NULL,
      "${_Column.createdAt}"	INTEGER NOT NULL)
    ''';

  static const String selectPayloadRecord = '''
    SELECT
      "${_Column.id}",
      "${_Column.accessToken}",
      "${_Column.endpoint}",
      "${_Column.config}",
      "${_Column.payload}",
      "${_Column.createdAt}"
    FROM "${_Column.name}"
    WHERE "${_Column.id}" = ?
    ''';

  static const String selectAllPayloadRecords = '''
    SELECT *
    FROM "${_Column.name}"
    ''';

  static const String insertPayloadRecord = '''
    INSERT INTO "${_Column.name}" (
      "${_Column.id}",
      "${_Column.accessToken}",
      "${_Column.endpoint}",
      "${_Column.config}",
      "${_Column.payload}",
      "${_Column.createdAt}")
    VALUES (?, ?, ?, ?, ?)
    ''';

  static const String deletePayloadRecord = '''
    DELETE FROM "${_Column.name}"
    WHERE "${_Column.id}" = ?
    ''';

  static const String deletePayloadRecordsOlderThan = '''
    DELETE FROM "${_Column.name}"
    WHERE "${_Column.createdAt}" <= ?
    ''';
}
