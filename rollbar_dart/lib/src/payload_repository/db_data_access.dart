import 'package:sqlite3/sqlite3.dart';

import 'package:rollbar_dart/src/payload_repository/destination.dart';
import 'package:rollbar_dart/src/payload_repository/payload_record.dart';

import '../_internal/database.dart';

class DbDataAccess {
  static const String dbFileName = 'rollbar_payloads.db';

  late final Database db;

  DbDataAccess initialize({required bool asPersistent}) {
    if (asPersistent) {
      db = sqlite3.open(dbFileName); //, mutex: true);
    } else {
      db = sqlite3.openInMemory();
    }

    _setupTablesAsNeeded();

    return this;
  }

  void _setupTablesAsNeeded() {
    var createTableCommnads = {
      DestinationsTable.tblName: DbSql.createDesinationsTableAsNeeded,
      PayloadRecordsTable.tblName: DbSql.createPayloadRecordsTableAsNeeded,
    };

    for (final tableName in createTableCommnads.keys) {
      db.execute(createTableCommnads[tableName]!);
    }
  }

  void deleteUnusedDestinations() {
    db.execute(DbSql.deleteUnusedDestinations);
  }

  void deleteDestination(Destination destination) {
    if (destination.id != null) {
      deleteDestinationWithID(destination.id!);
      // ignore: invalid_use_of_protected_member
      destination.assignID(null);
    }
  }

  void deleteDestinationWithID(int destinationID) {
    db.execute(DbSql.deleteDestinationWithID, [destinationID]);
  }

  void deletePayloadRecord(PayloadRecord record) {
    if (record.id != null) {
      deletePayloadRecordWithID(record.id!);
      // ignore: invalid_use_of_protected_member
      record.assignID(null);
    }
  }

  void deletePayloadRecordWithID(int recordID) {
    db.execute(DbSql.deletePayloadRecordWithID, [recordID]);
  }

  void deletePayloadRecordsOlderThan(DateTime utcExpirationTime) {
    db.execute(DbSql.deletePayloadRecordsOlderThan,
        [(utcExpirationTime.millisecondsSinceEpoch / 1000)]);
  }

  int insertDestination(Destination destination) {
    db.execute(DbSql.insertDestination,
        [destination.endpoint, destination.accessToken]);
    // ignore: invalid_use_of_protected_member
    destination.assignID(db.lastInsertRowId);
    return destination.id!;
  }

  int insertPayloadRecord(PayloadRecord payloadRecord) {
    db.execute(DbSql.insertPayloadRecord, [
      payloadRecord.configJson,
      payloadRecord.payloadJson,
      payloadRecord.destination.id,
      payloadRecord.timestamp.millisecondsSinceEpoch / 1000
    ]);
    // ignore: invalid_use_of_protected_member
    payloadRecord.assignID(db.lastInsertRowId);
    return payloadRecord.id!;
  }

  Iterable<Row> selectAllDestinations() =>
      db.select(DbSql.selectAllDestinations);

  Row? selectDestination(int id) =>
      db.select(DbSql.selectDestinationWithID, [id]).singleRow;

  int? findDestinationID({
    required String endpoint,
    required String accessToken,
  }) {
    final result = db.select(DbSql.findDestinationID, [endpoint, accessToken]);
    return result.singleRow?[DestinationsTable.colId];
  }

  Iterable<Row> selectAllPayloadRecords() =>
      db.select(DbSql.selectAllPayloadRecords);

  Iterable<Row> selectPayloadRecordsWithDestinationID(int destinationID) =>
      db.select(DbSql.selectPayloadRecordsWithDestinationID, [destinationID]);
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

class DbSql {
  static const String checkIfTableExists = '''
    SELECT name 
    FROM sqlite_master 
    WHERE type='table' AND name=?
    ''';
  static const String createDesinationsTableAsNeeded = '''
    CREATE TABLE IF NOT EXISTS "${DestinationsTable.tblName}" (
      "${DestinationsTable.colId}"	INTEGER NOT NULL PRIMARY KEY,
      "${DestinationsTable.colEndpoint}"	TEXT NOT NULL,
      "${DestinationsTable.colAccessToken}"	TEXT NOT NULL,
      CONSTRAINT "unique_destination" UNIQUE(
        "${DestinationsTable.colEndpoint}",
        "${DestinationsTable.colAccessToken}")
    )
    ''';
  static const String createPayloadRecordsTableAsNeeded = '''
    CREATE TABLE IF NOT EXISTS "${PayloadRecordsTable.tblName}" (
      "${PayloadRecordsTable.colId}"	INTEGER NOT NULL PRIMARY KEY,
      "${PayloadRecordsTable.colConfigJson}"	TEXT NOT NULL,
      "${PayloadRecordsTable.colPayloadJson}"	TEXT NOT NULL,
      "${PayloadRecordsTable.colCreatedAt}"	INTEGER NOT NULL,
      "${PayloadRecordsTable.colDestinationKey}"	INTEGER NOT NULL,
      FOREIGN KEY("${PayloadRecordsTable.colDestinationKey}")
        REFERENCES "${DestinationsTable.tblName}"("${DestinationsTable.colId}")
        ON UPDATE CASCADE
        ON DELETE CASCADE
    )
    ''';
  static const String deleteUnusedDestinations = '''
    DELETE FROM "${DestinationsTable.tblName}" 
    WHERE NOT EXISTS (
      SELECT 
      1
      FROM 
      "${PayloadRecordsTable.tblName}"
      WHERE
      "${PayloadRecordsTable.tblName}.${PayloadRecordsTable.colDestinationKey}" 
      = "${DestinationsTable.tblName}.${DestinationsTable.colId}" 
    )
    ''';
  static const String deleteDestinationWithID = '''
    DELETE FROM "${DestinationsTable.tblName}" 
    WHERE "${DestinationsTable.colId}" = ?
    ''';
  static const String deletePayloadRecordWithID = '''
    DELETE FROM "${PayloadRecordsTable.tblName}"
    WHERE "${PayloadRecordsTable.colId}" = ?
    ''';
  static const String deletePayloadRecordsOlderThan = '''
    DELETE FROM "${PayloadRecordsTable.tblName}" 
    WHERE "${PayloadRecordsTable.colCreatedAt}" <= ?
    ''';

  static const String insertDestination = '''
    INSERT INTO "${DestinationsTable.tblName}" (
      "${DestinationsTable.colEndpoint}", 
      "${DestinationsTable.colAccessToken}"
      )
    VALUES (?, ?)
    ''';
  static const String insertPayloadRecord = '''
    INSERT INTO "${PayloadRecordsTable.tblName}" (
      "${PayloadRecordsTable.colConfigJson}", 
      "${PayloadRecordsTable.colPayloadJson}", 
      "${PayloadRecordsTable.colDestinationKey}", 
      "${PayloadRecordsTable.colCreatedAt}"
      ) 
    VALUES (?, ?, ?, ?)
    ''';

  static const String selectAllDestinations = '''
    SELECT *
    FROM ${DestinationsTable.tblName}
    ''';
  static const String selectDestinationWithID = '''
    SELECT  
      "${DestinationsTable.colId}", 
      "${DestinationsTable.colEndpoint}", 
      "${DestinationsTable.colAccessToken}"
    FROM 
      "${DestinationsTable.tblName}"
    WHERE 
      "${DestinationsTable.colId}" = ?
    ''';

  static const String findDestinationID = '''
    SELECT 
      "${DestinationsTable.colId}"
    FROM 
      "${DestinationsTable.tblName}"
    WHERE 
      "${DestinationsTable.colEndpoint}" = ? 
      AND "${DestinationsTable.colAccessToken}" = ?
    ''';

  static const String selectAllPayloadRecords = '''
    SELECT * 
    FROM "${PayloadRecordsTable.tblName}"
    ''';
  static const String selectPayloadRecordsWithDestinationID = '''
    SELECT * 
    FROM "${PayloadRecordsTable.tblName}"
    WHERE "${PayloadRecordsTable.colDestinationKey}" = ?
    ''';
}
