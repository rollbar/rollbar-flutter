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
    return _selectAllDestinations();
  }

  Future<Set<PayloadRecord>> getPayloadRecords() async {
    return _selectAllPayloadRecords();
  }

  Future<Set<PayloadRecord>> getPayloadRecordsForDestination(
      Destination destination) async {
    if (destination.id != null) {
      return _selectPayloadRecordsWithDestinationID(destination.id!);
    }
    return <PayloadRecord>{};
  }

  Future<Set<PayloadRecord>> getPayloadRecordsWithDestinationID(
      int destinationID) async {
    return _selectPayloadRecordsWithDestinationID(destinationID);
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
      CREATE TABLE IF NOT EXISTS "${PayloadRecordsTable.tblName}" (
        "${PayloadRecordsTable.colId}"	INTEGER,
        "${PayloadRecordsTable.colConfigJson}"	TEXT NOT NULL,
        "${PayloadRecordsTable.colPayloadJson}"	TEXT NOT NULL,
        "${PayloadRecordsTable.colCreatedAt}"	INTEGER NOT NULL,
        "${PayloadRecordsTable.colDestinationKey}"	INTEGER,
        PRIMARY KEY("${PayloadRecordsTable.colId}" AUTOINCREMENT),
        FOREIGN KEY("${PayloadRecordsTable.colDestinationKey}")
          REFERENCES "${DestinationsTable.tblName}"("${DestinationsTable.colId}")
          ON UPDATE CASCADE
          ON DELETE CASCADE
      )
      ''',
    ];

    for (final cmd in createTableCommnads) {
      _db.execute(cmd);
    }
  }

  void _deletePayloadRecordsOlderThan(DateTime expirationTime) {
    final sqlStatement = _db.prepare('''
      DELETE FROM "${PayloadRecordsTable.tblName}" 
      WHERE "${PayloadRecordsTable.colCreatedAt}" <= ?
      ''');
    sqlStatement.execute([(expirationTime.millisecondsSinceEpoch / 1000)]);
    sqlStatement.dispose();
  }

  void _insertDestination(Destination destination) {
    final sqlStatement = _db.prepare('''
      INSERT INTO "${DestinationsTable.tblName}" (
        "${DestinationsTable.colEndpoint}", 
        "${DestinationsTable.colAccessToken}"
        )
      VALUES (?)
      ''');
    sqlStatement.execute([destination.endpoint, destination.accessToken]);
    sqlStatement.dispose();
  }

  void _insertPayloadRecord(PayloadRecord payloadRecord) {
    final sqlStatement = _db.prepare('''
        INSERT INTO "${PayloadRecordsTable.tblName}" (
          "${PayloadRecordsTable.colConfigJson}", 
          "${PayloadRecordsTable.colPayloadJson}", 
          "${PayloadRecordsTable.colDestinationKey}", 
          "${PayloadRecordsTable.colCreatedAt}"
          ) 
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

  Set<PayloadRecord> _selectAllPayloadRecords() {
    final ResultSet resultSet = _db.select('''
    SELECT * 
    FROM "${PayloadRecordsTable.tblName}"
    ''', []);

    final Set<PayloadRecord> payloadRecords = <PayloadRecord>{};
    for (final row in resultSet) {
      payloadRecords.add(_createPayloadRecord(row));
    }
    return payloadRecords;
  }

  Set<PayloadRecord> _selectPayloadRecordsWithDestinationID(int destinationID) {
    final ResultSet resultSet = _db.select('''
    SELECT * 
    FROM "${PayloadRecordsTable.tblName}"
    WHERE "${PayloadRecordsTable.colDestinationKey}" = ?
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
        id: dataRow[PayloadRecordsTable.colId],
        timestamp: DateTime.fromMillisecondsSinceEpoch(
            dataRow[PayloadRecordsTable.colCreatedAt] * 1000),
        configJson: dataRow[PayloadRecordsTable.colConfigJson],
        payloadJson: dataRow[PayloadRecordsTable.colPayloadJson],
        destinationID: dataRow[PayloadRecordsTable.colDestinationKey]);
  }
}

class DestinationsTable {
  static const String tblName = 'destinations';

  static const String colId = 'id';
  static const String colEndpoint = 'endpoint';
  static const String colAccessToken = 'access_token';
}

class PayloadRecordsTable {
  static const String tblName = 'payload_records';

  static const String colId = 'id';
  static const String colConfigJson = 'config_json';
  static const String colPayloadJson = 'payload_json';
  static const String colCreatedAt = 'created_at_utc_unix_epoch_sec';
  static const String colDestinationKey = 'destination_id';
}
