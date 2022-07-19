import 'dart:core';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:sqlite3/sqlite3.dart';

import '../ext/object.dart';
import '../ext/database.dart';
import '../ext/identifiable.dart';

import 'destination.dart';
import 'payload_record.dart';

extension _Columns on Row {
  Uint8List get id => this[TableDestinations.id];

  String get endpoint => this[TableDestinations.endpoint];
  String get accessToken => this[TableDestinations.accessToken];

  int get timestamp => this[TablePayloadRecords.createdAt];
  String get config => this[TablePayloadRecords.configJson];
  String get payload => this[TablePayloadRecords.payloadJson];
  Uint8List get destinationId => this[TablePayloadRecords.destinationId];
}

extension _Destination on Destination {
  static Destination from(Row row) => Destination(
      id: UUID.fromList(row.id),
      endpoint: row.endpoint,
      accessToken: row.accessToken);
}

extension _PayloadRecord on PayloadRecord {
  static PayloadRecord from(Row row, Destination destination) => PayloadRecord(
      id: UUID.fromList(row.id),
      timestamp:
          DateTime.fromMillisecondsSinceEpoch((row.timestamp * 1000).toInt()),
      configJson: row.config,
      payloadJson: row.payload,
      destination: destination);
}

@sealed
@immutable
class PayloadRepository {
  final Database databse;

  PayloadRepository({required bool persistent})
      : databse = persistent
            ? sqlite3.open('rollbar_payloads.db')
            : sqlite3.openInMemory() {
    [SQL.createDesinationsTable, SQL.createPayloadRecordsTable]
        .map(databse.execute);
  }
}

extension Destinations on PayloadRepository {
  Set<Destination> get destinations =>
      databse.select(SQL.selectAllDestinations).map(_Destination.from).toSet();

  Destination? destination({required UUID id}) => databse
      .select(SQL.selectDestinationWithID, [id.toBytes()])
      .singleRow
      .map(_Destination.from);

  UUID? destinationId({
    required String endpoint,
    required String accessToken,
  }) =>
      databse
          .select(SQL.findDestinationID, [endpoint, accessToken])
          .singleRow?[TableDestinations.id]
          .map(UUID.new);

  void addDestination(Destination destination) =>
      databse.execute(SQL.insertDestination, [
        destination.id.toBytes(),
        destination.endpoint,
        destination.accessToken
      ]);

  void removeUnusedDestinations() =>
      databse.execute(SQL.deleteUnusedDestinations);

  void removeDestination({required UUID id}) =>
      databse.execute(SQL.deleteDestinationWithID, [id.toBytes()]);
}

extension PayloadRecords on PayloadRepository {
  PayloadRecord? payloadRecord({required UUID id}) => databse
      .select(SQL.selectPayloadRecordWithID, [id.toBytes()])
      .singleRow
      .flatMap((row) {
        final uuid = UUID.fromList(row.destinationId);
        return destination(id: uuid).map((d) => _PayloadRecord.from(row, d));
      });

  Set<PayloadRecord> get payloadRecords {
    final destinations = {for (final d in this.destinations) d.id: d};
    return databse.select(SQL.selectAllPayloadRecords).map((row) {
      final id = UUID.fromList(row.destinationId);
      return _PayloadRecord.from(row, destinations[id]!);
    }).toSet();
  }

  Set<PayloadRecord> payloadRecordsForDestination(Destination destination) =>
      databse
          .select(SQL.selectPayloadRecordsWithDestinationID,
              [destination.id.toBytes()])
          .map((row) => _PayloadRecord.from(row, destination))
          .toSet();

  Set<PayloadRecord> getPayloadRecordsWithDestinationID(UUID id) =>
      destination(id: id).map(payloadRecordsForDestination) ?? {};

  void addPayloadRecord(PayloadRecord payloadRecord) {
    if (destination(id: payloadRecord.destination.id) == null) {
      addDestination(payloadRecord.destination);
    }

    databse.execute(SQL.insertPayloadRecord, [
      payloadRecord.id.toBytes(),
      payloadRecord.configJson,
      payloadRecord.payloadJson,
      payloadRecord.destination.id,
      payloadRecord.timestamp.millisecondsSinceEpoch / 1000
    ]);
  }

  void removePayloadRecord(PayloadRecord record) =>
      removePayloadRecordWithID(record.id);

  void removePayloadRecordWithID(UUID id) => databse.execute(
        SQL.deletePayloadRecordWithID,
        [id.toBytes()],
      );

  void removePayloadRecordsOlderThan(DateTime utcExpirationTime) =>
      databse.execute(SQL.deletePayloadRecordsOlderThan,
          [(utcExpirationTime.millisecondsSinceEpoch / 1000)]);
}

@sealed
@internal
class TableDestinations {
  static const String name = 'destinations';

  static const String id = 'id';
  static const String endpoint = 'endpoint';
  static const String accessToken = 'access_token';
}

@sealed
@internal
class TablePayloadRecords {
  static const String name = 'payload_records';

  static const String id = 'id';
  static const String configJson = 'config_json';
  static const String payloadJson = 'payload_json';
  static const String createdAt = 'created_at_utc_unix_epoch_sec';
  static const String destinationId = 'destination_id';
}

@sealed
@internal
class SQL {
  static const String checkIfTableExists = '''
    SELECT name
    FROM sqlite_master
    WHERE type='table' AND name=?
    ''';

  static const String createDesinationsTable = '''
    CREATE TABLE IF NOT EXISTS "${TableDestinations.name}" (
      "${TableDestinations.id}"	BINARY(16) NOT NULL PRIMARY KEY,
      "${TableDestinations.endpoint}"	TEXT NOT NULL,
      "${TableDestinations.accessToken}"	TEXT NOT NULL,
      CONSTRAINT "unique_destination" UNIQUE(
        "${TableDestinations.id}",
        "${TableDestinations.endpoint}",
        "${TableDestinations.accessToken}")
    )
    ''';
  static const String createPayloadRecordsTable = '''
    CREATE TABLE IF NOT EXISTS "${TablePayloadRecords.name}" (
      "${TablePayloadRecords.id}"	BINARY(16) NOT NULL PRIMARY KEY,
      "${TablePayloadRecords.configJson}"	TEXT NOT NULL,
      "${TablePayloadRecords.payloadJson}"	TEXT NOT NULL,
      "${TablePayloadRecords.createdAt}"	INTEGER NOT NULL,
      "${TablePayloadRecords.destinationId}"	BINARY(16) NOT NULL,
      FOREIGN KEY("${TablePayloadRecords.destinationId}")
        REFERENCES "${TableDestinations.name}"("${TableDestinations.id}")
        ON UPDATE CASCADE
        ON DELETE CASCADE
    )
    ''';
  static const String deleteUnusedDestinations = '''
    DELETE FROM "${TableDestinations.name}"
    WHERE NOT EXISTS (
      SELECT 1 FROM
      "${TablePayloadRecords.name}"
      WHERE
      "${TablePayloadRecords.name}.${TablePayloadRecords.destinationId}"
      = "${TableDestinations.name}.${TableDestinations.id}"
    )
    ''';
  static const String deleteDestinationWithID = '''
    DELETE FROM "${TableDestinations.name}"
    WHERE "${TableDestinations.id}" = ?
    ''';
  static const String deletePayloadRecordWithID = '''
    DELETE FROM "${TablePayloadRecords.name}"
    WHERE "${TablePayloadRecords.id}" = ?
    ''';
  static const String deletePayloadRecordsOlderThan = '''
    DELETE FROM "${TablePayloadRecords.name}"
    WHERE "${TablePayloadRecords.createdAt}" <= ?
    ''';

  static const String insertDestination = '''
    INSERT INTO "${TableDestinations.name}" (
      "${TableDestinations.id}",
      "${TableDestinations.endpoint}",
      "${TableDestinations.accessToken}")
    VALUES (?, ?, ?)
    ''';
  static const String insertPayloadRecord = '''
    INSERT INTO "${TablePayloadRecords.name}" (
      "${TablePayloadRecords.id}",
      "${TablePayloadRecords.configJson}",
      "${TablePayloadRecords.payloadJson}",
      "${TablePayloadRecords.destinationId}",
      "${TablePayloadRecords.createdAt}")
    VALUES (?, ?, ?, ?, ?)
    ''';

  static const String selectAllDestinations = '''
    SELECT *
    FROM ${TableDestinations.name}
    ''';
  static const String selectDestinationWithID = '''
    SELECT
      "${TableDestinations.id}",
      "${TableDestinations.endpoint}",
      "${TableDestinations.accessToken}"
    FROM
      "${TableDestinations.name}"
    WHERE
      "${TableDestinations.id}" = ?
    ''';
  static const String selectPayloadRecordWithID = '''
    SELECT
      "${TablePayloadRecords.id}",
      "${TablePayloadRecords.configJson}",
      "${TablePayloadRecords.payloadJson}",
      "${TablePayloadRecords.destinationId}",
      "${TablePayloadRecords.createdAt}"
    FROM
      "${TablePayloadRecords.name}"
    WHERE
      "${TablePayloadRecords.id}" = ?
    ''';

  static const String findDestinationID = '''
    SELECT "${TableDestinations.id}"
    FROM "${TableDestinations.name}"
    WHERE
      "${TableDestinations.endpoint}" = ?
      AND "${TableDestinations.accessToken}" = ?
    ''';

  static const String selectAllPayloadRecords = '''
    SELECT *
    FROM "${TablePayloadRecords.name}"
    ''';
  static const String selectPayloadRecordsWithDestinationID = '''
    SELECT *
    FROM "${TablePayloadRecords.name}"
    WHERE "${TablePayloadRecords.destinationId}" = ?
    ''';
}
