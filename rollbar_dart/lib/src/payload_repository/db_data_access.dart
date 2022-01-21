import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import 'package:rollbar_dart/src/payload_repository/destination.dart';
import 'package:rollbar_dart/src/payload_repository/payload_record.dart';

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

  bool _checkTableExists(String tableName) {
    final cmd = '''
    SELECT name 
    FROM sqlite_master 
    WHERE type='table' AND name='$tableName'
    ''';
    return db.select(cmd, []).isNotEmpty;
  }

  void _setupTablesAsNeeded() {
    var createTableCommnads = {
      DestinationsTable.tblName: '''
      CREATE TABLE IF NOT EXISTS "${DestinationsTable.tblName}" (
        "${DestinationsTable.colId}"	INTEGER NOT NULL PRIMARY KEY,
        "${DestinationsTable.colEndpoint}"	TEXT NOT NULL,
        "${DestinationsTable.colAccessToken}"	TEXT NOT NULL,
        CONSTRAINT "unique_destination" UNIQUE(
          "${DestinationsTable.colEndpoint}",
          "${DestinationsTable.colAccessToken}")
      )
      ''',
      PayloadRecordsTable.tblName: '''
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
      ''',
    };

    for (final tableName in createTableCommnads.keys) {
      if (!_checkTableExists(tableName)) {
        db.execute(createTableCommnads[tableName]!);
      }
    }
  }

  void deleteUnusedDestinations() {
    // final sqlStatement = db.prepare('''
    //   DELETE FROM "${DestinationsTable.tblName}"
    //   WHERE NOT EXISTS (
    //     SELECT
    //     1
    //     FROM
    //     "${PayloadRecordsTable.tblName}"
    //     WHERE
    //     "${PayloadRecordsTable.tblName}.${PayloadRecordsTable.colDestinationKey}"
    //     = "${DestinationsTable.tblName}.${DestinationsTable.colId}"
    //   )
    //   ''');
    // sqlStatement.execute([]);
    // sqlStatement.dispose();

    db.execute('''
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
      ''');
  }

  void deleteDestination(Destination destination) {
    if (destination.id != null) {
      deleteDestinationWithID(destination.id!);
      // ignore: invalid_use_of_protected_member
      destination.assignID(null);
    }
  }

  void deleteDestinationWithID(int destinationID) {
    final sqlStatement = db.prepare('''
      DELETE FROM "${DestinationsTable.tblName}" 
      WHERE "${PayloadRecordsTable.colId}" = ?
      ''');
    sqlStatement.execute([destinationID]);
    sqlStatement.dispose();
  }

  void deletePayloadRecord(PayloadRecord record) {
    if (record.id != null) {
      deletePayloadRecordWithID(record.id!);
      // ignore: invalid_use_of_protected_member
      record.assignID(null);
    }
  }

  void deletePayloadRecordWithID(int recordID) {
    final sqlStatement = db.prepare('''
      DELETE FROM "${PayloadRecordsTable.tblName}" 
      WHERE "${PayloadRecordsTable.colId}" = ?
      ''');
    sqlStatement.execute([recordID]);
    sqlStatement.dispose();
  }

  void deletePayloadRecordsOlderThan(DateTime utcExpirationTime) {
    final sqlStatement = db.prepare('''
      DELETE FROM "${PayloadRecordsTable.tblName}" 
      WHERE "${PayloadRecordsTable.colCreatedAt}" <= ?
      ''');
    sqlStatement.execute([(utcExpirationTime.millisecondsSinceEpoch / 1000)]);
    sqlStatement.dispose();
  }

  int insertDestination(Destination destination) {
    final sqlStatement = db.prepare('''
      INSERT INTO "${DestinationsTable.tblName}" (
        "${DestinationsTable.colEndpoint}", 
        "${DestinationsTable.colAccessToken}"
        )
      VALUES (?, ?)
      ''');

    sqlStatement.execute([destination.endpoint, destination.accessToken]);

    // ignore: invalid_use_of_protected_member
    destination.assignID(db.lastInsertRowId);
    print('destination ID: ${destination.id}');
    sqlStatement.dispose();
    return destination.id!;
  }

  int insertPayloadRecord(PayloadRecord payloadRecord) {
    final sqlStatement = db.prepare('''
        INSERT INTO "${PayloadRecordsTable.tblName}" (
          "${PayloadRecordsTable.colConfigJson}", 
          "${PayloadRecordsTable.colPayloadJson}", 
          "${PayloadRecordsTable.colDestinationKey}", 
          "${PayloadRecordsTable.colCreatedAt}"
          ) 
        VALUES (?, ?, ?, ?)
        ''');

    sqlStatement.execute([
      payloadRecord.configJson,
      payloadRecord.payloadJson,
      payloadRecord.destination.id,
      payloadRecord.timestamp.millisecondsSinceEpoch / 1000
      //'strftime("%s","now")' //unixepoch time, read it by selecting: datetime(date_column,'unixepoch')
    ]);
    sqlStatement.dispose();

    // ignore: invalid_use_of_protected_member
    payloadRecord.assignID(db.lastInsertRowId);
    return payloadRecord.id!;
  }

  Iterable<Row> selectAllDestinations() {
    final ResultSet resultSet = db.select('''
    SELECT 
    "${DestinationsTable.colId}", 
    "${DestinationsTable.colEndpoint}", 
    "${DestinationsTable.colAccessToken}" 
    FROM 
    "${DestinationsTable.tblName}"
    ''');
    return resultSet;
  }

  Row? selectDestination(int id) {
    final ResultSet resultSet = db.select('''
    SELECT "${DestinationsTable.colId}", "${DestinationsTable.colEndpoint}", "${DestinationsTable.colAccessToken}"
    FROM "${DestinationsTable.tblName}"
    WHERE "${DestinationsTable.colId}" = ?
    ''', [id]);
    if (resultSet.isEmpty) {
      return null;
    }
    if (resultSet.isEmpty) {
      return null;
    } else {
      return resultSet.first;
    }
  }

  int? findDestinationID(
      {required String endpoint, required String accessToken}) {
    final ResultSet resultSet = db.select('''
    SELECT "${DestinationsTable.colId}"
    FROM "${DestinationsTable.tblName}"
    WHERE "${DestinationsTable.colEndpoint}" = ? AND "${DestinationsTable.colAccessToken}" = ?
    ''', [endpoint, accessToken]);

    if (resultSet.isEmpty) {
      return null;
    } else if (resultSet.length > 1) {
      //TODO: we may want to trace this here as an odd problem...
      return null;
    } else {
      for (final row in resultSet) {
        return row[DestinationsTable.colId];
      }
    }
  }

  Iterable<Row> selectAllPayloadRecords() {
    final ResultSet resultSet = db.select('''
    SELECT * 
    FROM "${PayloadRecordsTable.tblName}"
    ''', []);
    return resultSet;
  }

  Iterable<Row> selectPayloadRecordsWithDestinationID(int destinationID) {
    final ResultSet resultSet = db.select('''
    SELECT * 
    FROM "${PayloadRecordsTable.tblName}"
    WHERE "${PayloadRecordsTable.colDestinationKey}" = ?
    ''', [destinationID]);
    return resultSet;
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
