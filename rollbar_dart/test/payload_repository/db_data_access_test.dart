import 'dart:io';

import 'package:rollbar_dart/src/payload_repository/db_data_access.dart';
import 'package:test/test.dart';

import 'package:rollbar_dart/src/payload_repository/destination.dart';
import 'package:rollbar_dart/src/payload_repository/payload_record.dart';

void main() {
  group('DbDataAccess:', () {
    setUp(() {
      // Additional setup goes here.
      _cleanup();
    });

    tearDown(() {
      _cleanup();
    });

    test('Persistent vs non-persistent data store...', () {
      var dbFile = File(DbDataAccess.dbFileName);
      expect(dbFile.existsSync(), false);

      DbDataAccess().initialize(asPersistent: false);
      expect(dbFile.existsSync(), false);

      DbDataAccess().initialize(asPersistent: true);
      expect(dbFile.existsSync(), true);
    });
    test('Basic Destination entities manipulation...', () {
      final dbAccess = DbDataAccess().initialize(asPersistent: false);
      expect(dbAccess.selectAllDestinations().length, 0);

      // insert new destination:
      const destination =
          Destination(endpoint: 'wwww.site.com', accessToken: 'TOKEN1');
      var id = dbAccess.insertDestination(destination);
      expect(id, 1);

      // refuses to insert the same destination more than once:
      expect(() => dbAccess.insertDestination(destination), throwsException);

      // insert another destination:
      const destination2 =
          Destination(endpoint: 'wwww.site.com', accessToken: 'TOKEN2');
      id = dbAccess.insertDestination(destination2);
      expect(id, 2);

      // refuses to insert similar destination:
      const destination3 =
          Destination(endpoint: 'wwww.site.com', accessToken: 'TOKEN2');
      expect(() => dbAccess.insertDestination(destination3), throwsException);

      // verify total count of inserted destinations:
      expect(dbAccess.selectAllDestinations().length, 2);

      // verify that we can delete unused destinations:
      dbAccess.deleteUnusedDestinations();
      expect(dbAccess.selectAllDestinations().length, 0);
    });

    test('Basic PayloadRecord entities manipulation...', () {
      final dbAccess = DbDataAccess().initialize(asPersistent: false);
      expect(dbAccess.selectAllDestinations().length, 0);
      expect(dbAccess.selectAllPayloadRecords().length, 0);

      // insert new destination:
      final destination1 =
          Destination(endpoint: 'wwww.site.com', accessToken: 'TOKEN1');
      var id = dbAccess.insertDestination(destination1);
      expect(id, 1);

      // insert another destination:
      final destination2 =
          Destination(endpoint: 'wwww.site.com', accessToken: 'TOKEN2');
      id = dbAccess.insertDestination(destination2);
      expect(id, 2);

      int recordsCount = 0;
      int destination1RecordsCount = 0;
      int destination2RecordsCount = 0;
      expect(dbAccess.selectAllPayloadRecords().length, recordsCount);
      expect(
          dbAccess
              .selectPayloadRecordsWithDestinationID(destination1.id ?? 0)
              .length,
          destination1RecordsCount);
      expect(
          dbAccess
              .selectPayloadRecordsWithDestinationID(destination2.id ?? 0)
              .length,
          destination2RecordsCount);

      final record11 = PayloadRecord(
          configJson: 'CONFIG1',
          payloadJson: 'PAYLOAD1',
          destination: destination1,
          timestamp: DateTime.now().toUtc());
      id = dbAccess.insertPayloadRecord(record11);
      expect(id, 1);
      expect(dbAccess.selectAllPayloadRecords().length, ++recordsCount);
      expect(
          dbAccess
              .selectPayloadRecordsWithDestinationID(destination1.id ?? 0)
              .length,
          ++destination1RecordsCount);

      final record12 = PayloadRecord(
          configJson: 'CONFIG1',
          payloadJson: 'PAYLOAD1',
          destination: destination1,
          timestamp: DateTime.now().toUtc());
      id = dbAccess.insertPayloadRecord(record12);
      expect(id, 2);
      expect(dbAccess.selectAllPayloadRecords().length, ++recordsCount);
      expect(
          dbAccess
              .selectPayloadRecordsWithDestinationID(destination1.id ?? 0)
              .length,
          ++destination1RecordsCount);

      final record21 = PayloadRecord(
          configJson: 'CONFIG2',
          payloadJson: 'PAYLOAD21',
          destination: destination2,
          timestamp: DateTime.now().toUtc());
      id = dbAccess.insertPayloadRecord(record21);
      expect(id, 3);
      expect(dbAccess.selectAllPayloadRecords().length, ++recordsCount);
      expect(
          dbAccess
              .selectPayloadRecordsWithDestinationID(destination2.id ?? 0)
              .length,
          ++destination2RecordsCount);

      final record22 = PayloadRecord(
          configJson: 'CONFIG2',
          payloadJson: 'PAYLOAD22',
          destination: destination2,
          timestamp: DateTime.now().toUtc());
      id = dbAccess.insertPayloadRecord(record22);
      expect(id, 4);
      expect(dbAccess.selectAllPayloadRecords().length, ++recordsCount);
      expect(
          dbAccess
              .selectPayloadRecordsWithDestinationID(destination2.id ?? 0)
              .length,
          ++destination2RecordsCount);

      dbAccess.deletePayloadRecord(record22);
      expect(dbAccess.selectAllPayloadRecords().length, --recordsCount);
      expect(
          dbAccess
              .selectPayloadRecordsWithDestinationID(destination2.id ?? 0)
              .length,
          --destination2RecordsCount);

      dbAccess.deletePayloadRecord(record21);
      expect(dbAccess.selectAllPayloadRecords().length, --recordsCount);
      expect(
          dbAccess
              .selectPayloadRecordsWithDestinationID(destination2.id ?? 0)
              .length,
          --destination2RecordsCount);

      expect(dbAccess.selectAllPayloadRecords().isNotEmpty, true);
      dbAccess.deletePayloadRecordsOlderThan(DateTime.now().toUtc());
      expect(dbAccess.selectAllPayloadRecords().length, 0);

      // verify that we can delete unused destinations:
      dbAccess.deleteUnusedDestinations();
      expect(dbAccess.selectAllDestinations().length, 0);
    });
  });
}

void _cleanup() {
  var dbFile = File(DbDataAccess.dbFileName);
  if (dbFile.existsSync()) {
    dbFile.deleteSync();
  }
}
