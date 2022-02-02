import 'package:sqlite3/sqlite3.dart';

import 'package:rollbar_dart/src/payload_repository/destination.dart';
import 'package:rollbar_dart/src/payload_repository/payload_record.dart';

class DbDataAccess {
  static const String dbFileName = 'rollbar_payloads.db';

  late final Database db;

  // late final PreparedStatement _cmdDeleteUnusedDestinations;
  // late final PreparedStatement _cmdDeleteDestinationWithID;
  // late final PreparedStatement _cmdDeletePayloadRecordWithID;
  // late final PreparedStatement _cmdDeletePayloadRecordsOlderThan;
  // late final PreparedStatement _cmdInsertDestination;
  // late final PreparedStatement _cmdInsertPayloadRecord;
  // late final PreparedStatement _cmdSelectAllDestinations;
  // late final PreparedStatement _cmdSelectDestinationWithID;
  // late final PreparedStatement _cmdFindDestinationID;
  // late final PreparedStatement _cmdSelectAllPayloadRecords;
  // late final PreparedStatement _cmdSelectPayloadRecordsWithDestinationID;

  DbDataAccess initialize({required bool asPersistent}) {
    if (asPersistent) {
      db = sqlite3.open(dbFileName); //, mutex: true);
    } else {
      db = sqlite3.openInMemory();
    }

    _setupTablesAsNeeded();

    // _cmdDeleteUnusedDestinations =
    //     db.prepare(DbSql.deleteUnusedDestinations, persistent: true);
    // _cmdDeleteDestinationWithID =
    //     db.prepare(DbSql.deleteDestinationWithID, persistent: true);
    // _cmdDeletePayloadRecordWithID =
    //     db.prepare(DbSql.deletePayloadRecordWithID, persistent: true);
    // _cmdDeletePayloadRecordsOlderThan =
    //     db.prepare(DbSql.deletePayloadRecordsOlderThan, persistent: true);
    // _cmdInsertDestination =
    //     db.prepare(DbSql.insertDestination, persistent: true);
    // _cmdInsertPayloadRecord =
    //     db.prepare(DbSql.insertPayloadRecord, persistent: true);
    // _cmdSelectAllDestinations =
    //     db.prepare(DbSql.selectAllDestinations, persistent: true);
    // _cmdSelectDestinationWithID =
    //     db.prepare(DbSql.selectDestinationWithID, persistent: true);
    // _cmdFindDestinationID =
    //     db.prepare(DbSql.findDestinationID, persistent: true);
    // _cmdSelectAllPayloadRecords =
    //     db.prepare(DbSql.selectAllPayloadRecords, persistent: true);
    // _cmdSelectPayloadRecordsWithDestinationID = db
    //     .prepare(DbSql.selectPayloadRecordsWithDestinationID, persistent: true);

    return this;
  }

  // void dispose() {
  //   _cmdDeleteUnusedDestinations.dispose();
  //   _cmdDeleteDestinationWithID.dispose();
  //   _cmdDeletePayloadRecordWithID.dispose();
  //   _cmdDeletePayloadRecordsOlderThan.dispose();
  //   _cmdInsertDestination.dispose();
  //   _cmdInsertPayloadRecord.dispose();
  //   _cmdSelectAllDestinations.dispose();
  //   _cmdSelectDestinationWithID.dispose();
  //   _cmdFindDestinationID.dispose();
  //   _cmdSelectAllPayloadRecords.dispose();
  //   _cmdSelectPayloadRecordsWithDestinationID.dispose();
  // }

  // bool _checkTableExists(String tableName) {
  //   return db.select(DbSql.checkIfTableExists, [tableName]).isNotEmpty;
  // }

  void _setupTablesAsNeeded() {
    var createTableCommnads = {
      DestinationsTable.tblName: DbSql.createDesinationsTableAsNeeded,
      PayloadRecordsTable.tblName: DbSql.createPayloadRecordsTableAsNeeded,
    };

    for (final tableName in createTableCommnads.keys) {
      // if (!_checkTableExists(tableName)) {
      //   db.execute(createTableCommnads[tableName]!);
      // }
      db.execute(createTableCommnads[tableName]!);
    }
  }

  void deleteUnusedDestinations() {
    // _cmdDeleteUnusedDestinations.execute();
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
    // _cmdDeleteDestinationWithID.execute([destinationID]);
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
    // _cmdDeletePayloadRecordWithID.execute([recordID]);
    db.execute(DbSql.deletePayloadRecordWithID, [recordID]);
  }

  void deletePayloadRecordsOlderThan(DateTime utcExpirationTime) {
    // _cmdDeletePayloadRecordsOlderThan
    //     .execute([(utcExpirationTime.millisecondsSinceEpoch / 1000)]);
    db.execute(DbSql.deletePayloadRecordsOlderThan,
        [(utcExpirationTime.millisecondsSinceEpoch / 1000)]);
  }

  int insertDestination(Destination destination) {
    // _cmdInsertDestination
    //     .execute([destination.endpoint, destination.accessToken]);
    db.execute(DbSql.insertDestination,
        [destination.endpoint, destination.accessToken]);
    // ignore: invalid_use_of_protected_member
    destination.assignID(db.lastInsertRowId);
    return destination.id!;
  }

  int insertPayloadRecord(PayloadRecord payloadRecord) {
    // _cmdInsertPayloadRecord.execute([
    //   payloadRecord.configJson,
    //   payloadRecord.payloadJson,
    //   payloadRecord.destination.id,
    //   payloadRecord.timestamp.millisecondsSinceEpoch / 1000
    //   //'strftime("%s","now")' //unixepoch time, read it by selecting: datetime(date_column,'unixepoch')
    // ]);
    db.execute(DbSql.insertPayloadRecord, [
      payloadRecord.configJson,
      payloadRecord.payloadJson,
      payloadRecord.destination.id,
      payloadRecord.timestamp.millisecondsSinceEpoch / 1000
      //'strftime("%s","now")' //unixepoch time, read it by selecting: datetime(date_column,'unixepoch')
    ]);
    // ignore: invalid_use_of_protected_member
    payloadRecord.assignID(db.lastInsertRowId);
    return payloadRecord.id!;
  }

  Iterable<Row> selectAllDestinations() {
    //return _cmdSelectAllDestinations.select();
    return db.select(DbSql.selectAllDestinations);
  }

  Row? selectDestination(int id) {
    final ResultSet resultSet = db.select(DbSql.selectDestinationWithID, [id]);
    if (resultSet.isEmpty) {
      return null;
    } else if (resultSet.length > 1) {
      //TODO: we may want to trace this here as an odd problem...
      return null;
    } else {
      return resultSet.first;
    }
  }

  int? findDestinationID(
      {required String endpoint, required String accessToken}) {
    final ResultSet resultSet =
        db.select(DbSql.findDestinationID, [endpoint, accessToken]);

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
    final ResultSet resultSet = db.select(DbSql.selectAllPayloadRecords);
    return resultSet;
  }

  Iterable<Row> selectPayloadRecordsWithDestinationID(int destinationID) {
    final ResultSet resultSet =
        db.select(DbSql.selectPayloadRecordsWithDestinationID, [destinationID]);
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

  // static const String selectAllDestinations = '''
  //   SELECT
  //     "${DestinationsTable.colId}",
  //     "${DestinationsTable.colEndpoint}",
  //     "${DestinationsTable.colAccessToken}"
  //   FROM
  //     "${DestinationsTable.tblName}"
  //   ''';
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
