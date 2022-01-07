import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import 'destination.dart';
import 'payload_record.dart';

class PayloadRepository {
  static const String dbFileName = 'rollbar_payloads.db';
  final Database _db;

  static Future<Database> _opnDB(bool persistent) async {
    if (persistent) {
      return sqlite3.open(dbFileName);
    } else {
      return sqlite3.openInMemory();
    }
  }

  PayloadRepository(this._db);

  static Future<PayloadRepository> create(bool persistent) async {
    var db = await _opnDB(persistent);
    return PayloadRepository(db);
  }

  static Future<PayloadRepository> createInMemory() async {
    return create(false);
  }

  static Future<PayloadRepository> createPersistent() async {
    return create(true);
  }

  Future<Set<Destination>> getDestinations() async {
    return <Destination>{};
  }

  Future<Set<PayloadRecord>> getPayloadRecords() async {
    return <PayloadRecord>{};
  }

  Future<Set<PayloadRecord>> getPayloadRecordsForDestination(
      Destination destination) async {
    return <PayloadRecord>{};
  }

  Future<Set<PayloadRecord>> getPayloadRecordsWithDestinationID(
      int destinationID) async {
    return <PayloadRecord>{};
  }

  void _setupTables() {
    var createTableCommnads = <String>[
      '''
      CREATE TABLE IF NOT EXISTS "${DestinationsTable.tblName}" (
        "${DestinationsTable.colId}"	INTEGER,
        "${DestinationsTable.colEndpoint}"	TEXT NOT NULL,
        "${DestinationsTable.colAccessToken}"	TEXT NOT NULL,
        PRIMARY KEY("${DestinationsTable.colId}" AUTOINCREMENT),
        CONSTRAINT "unique_destination" UNIQUE(
          "${DestinationsTable.colEndpoint}",
          "${DestinationsTable.colAccessToken}")
      )
      ''',
      '''
      CREATE TABLE IF NOT EXISTS "payload_records" (
        "id"	INTEGER,
        "config_json"	TEXT NOT NULL,
        "payload_json"	TEXT NOT NULL,
        "created_at_utc_unix_epoch_sec"	INTEGER NOT NULL,
        "destination_id"	INTEGER,
        PRIMARY KEY("id" AUTOINCREMENT),
        FOREIGN KEY("destination_id")
          REFERENCES "destinations"("id")
          ON UPDATE CASCADE
          ON DELETE CASCADE
      )
      ''',
    ];

    for (final cmd in createTableCommnads) {
      _db.execute(cmd);
    }
  }

  void _insertDestination(Destination destination) {
    final sqlStatement = _db.prepare('''
      INSERT INTO "${DestinationsTable.tblName}"
      ("${DestinationsTable.colEndpoint}", "${DestinationsTable.colAccessToken}")
      VALUES (?)
      ''');
    sqlStatement.execute([destination.endpoint, destination.accessToken]);
    sqlStatement.dispose();
  }

  void _insertPayloadRecord(PayloadRecord payloadRecord) {
    final sqlStatement = _db.prepare('''
        INSERT INTO "payload_records" 
        ("config_json", "payload_json", "destination_id", "created_at_utc_unix_epoch_sec") 
        VALUES (?)
        ''');

    sqlStatement.execute([
      payloadRecord.configJson,
      payloadRecord.payloadJson,
      payloadRecord.destinationID,
      'strftime("%s","now")' //unixepoch time, read it by selecting: datetime(date_column,'unixepoch')
    ]);
    sqlStatement.dispose();
  }

  Set<Destination> _selectAllDestinations() {
    final ResultSet resultSet = _db.select('''
    SELECT * 
    FROM "${DestinationsTable.tblName}"
    ''');

    final Set<Destination> destinations = <Destination>{};
    for (final row in resultSet) {
      destinations.add(_createDestination(row));
    }
    return destinations;
  }

  Destination? _selectDestination(int id) {
    final ResultSet resultSet = _db.select('''
    SELECT * 
    FROM "${DestinationsTable.tblName}"
    WHERE "${DestinationsTable.colId}" = ?
    ''', [id]);
    if (resultSet.isEmpty) {
      return null;
    }

    final Set<Destination> destinations = <Destination>{};
    for (final row in resultSet) {
      destinations.add(_createDestination(row));
    }
    return destinations.first;
  }

  Set<PayloadRecord> _selectPayloadRecordsWithDestinationID(int destinationID) {
    final ResultSet resultSet = _db.select('''
    SELECT * 
    FROM "payload_records"
    WHERE "destination_id" = ?
    ''', [destinationID]);

    final Set<PayloadRecord> payloadRecords = <PayloadRecord>{};
    for (final row in resultSet) {
      payloadRecords.add(_createPayloadRecord(row));
    }
    return payloadRecords;
  }

  static Destination _createDestination(Row dataRow) {
    return Destination(
        id: dataRow[DestinationsTable.colId],
        endpoint: dataRow[DestinationsTable.colEndpoint],
        accessToken: dataRow[DestinationsTable.colAccessToken]);
  }

  static PayloadRecord _createPayloadRecord(Row dataRow) {
    return PayloadRecord(
        id: dataRow['id'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(
            dataRow['created_at_utc_unix_epoch_sec'] * 1000),
        configJson: dataRow['config_json'],
        payloadJson: dataRow['payload_json'],
        destinationID: dataRow['destination_id']);
  }
}

class DestinationsTable {
  static const String tblName = 'destinations';

  static const String colId = 'id';
  static const String colEndpoint = 'endpoint';
  static const String colAccessToken = 'access_token';
}
