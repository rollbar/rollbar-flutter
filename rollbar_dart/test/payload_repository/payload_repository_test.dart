import 'dart:io';

import 'package:rollbar_dart/src/payload_repository/db_data_access.dart';
import 'package:test/test.dart';

import 'package:rollbar_dart/src/payload_repository/destination.dart';
import 'package:rollbar_dart/src/payload_repository/payload_record.dart';
import 'package:rollbar_dart/src/payload_repository/payload_repository.dart';

void main() {
  group('Payload Repository:', () {
    setUp(() {
      // Additional setup goes here.
      _cleanup();
    });

    tearDown(() {
      _cleanup();
    });

    test('Persistent vs non-persistent repository...', () async {
      var dbFile = File(DbDataAccess.dbFileName);
      expect(dbFile.existsSync(), false);

      PayloadRepository(persistent: false);
      expect(dbFile.existsSync(), false);

      PayloadRepository(persistent: true);
      expect(dbFile.existsSync(), true);
    });

    test('Basic Destination entities manipulation...', () async {
      final repo = PayloadRepository(persistent: false);
      expect(repo.destinations.length, 0);

      // insert new destination:
      const destination =
          Destination(endpoint: 'wwww.site.com', accessToken: 'TOKEN1');
      await repo.addDestinationAsync(destination);

      repo.expect(id, 1);

      // refuses to insert the same destination more than once:
      expect(() async => await repo.addDestinationAsync(destination),
          throwsException);

      // insert another destination:
      const destination2 =
          Destination(endpoint: 'wwww.site.com', accessToken: 'TOKEN2');
      id = await repo.addDestinationAsync(destination2);
      expect(id, 2);

      // refuses to insert similar destination:
      const destination3 =
          Destination(endpoint: 'wwww.site.com', accessToken: 'TOKEN2');
      expect(() async => await repo.addDestinationAsync(destination3),
          throwsException);

      // verify total count of inserted destinations:
      expect((await repo.getDestinationsAsync()).length, 2);

      // verify that we can delete unused destinations:
      await repo.removeUnusedDestinationsAsync();
      expect((await repo.getDestinationsAsync()).length, 0);
    });

    test('Basic PayloadRecord entities manipulation...', () async {
      final repo = PayloadRepository(persistent: false);
      expect((await repo.getDestinationsAsync()).length, 0);
      expect((await repo.getPayloadRecordsAsync()).length, 0);

      // insert new destination:
      const destination1 =
          Destination(endpoint: 'wwww.site.com', accessToken: 'TOKEN1');
      var id = await repo.addDestinationAsync(destination1);
      expect(id, 1);

      // insert another destination:
      const destination2 =
          Destination(endpoint: 'wwww.site.com', accessToken: 'TOKEN2');
      id = await repo.addDestinationAsync(destination2);
      expect(id, 2);

      int recordsCount = 0;
      int destination1RecordsCount = 0;
      int destination2RecordsCount = 0;
      expect((await repo.getPayloadRecordsAsync()).length, recordsCount);
      expect(
          (await repo.getPayloadRecordsWithDestinationIDAsync(
                  destination1.id ?? 0))
              .length,
          destination1RecordsCount);
      expect(
          (await repo.getPayloadRecordsWithDestinationIDAsync(
                  destination2.id ?? 0))
              .length,
          destination2RecordsCount);

      final record11 = PayloadRecord(
          configJson: 'CONFIG1',
          payloadJson: 'PAYLOAD1',
          destination: destination1,
          timestamp: DateTime.now().toUtc());
      id = await repo.addPayloadRecordAsync(record11);
      expect(id, 1);
      expect((await repo.getPayloadRecordsAsync()).length, ++recordsCount);
      expect(
          (await repo.getPayloadRecordsWithDestinationIDAsync(
                  destination1.id ?? 0))
              .length,
          ++destination1RecordsCount);

      final record12 = PayloadRecord(
          configJson: 'CONFIG1',
          payloadJson: 'PAYLOAD1',
          destination: destination1,
          timestamp: DateTime.now().toUtc());
      id = await repo.addPayloadRecordAsync(record12);
      expect(id, 2);
      expect((await repo.getPayloadRecordsAsync()).length, ++recordsCount);
      expect(
          (await repo.getPayloadRecordsWithDestinationIDAsync(
                  destination1.id ?? 0))
              .length,
          ++destination1RecordsCount);

      final record21 = PayloadRecord(
          configJson: 'CONFIG2',
          payloadJson: 'PAYLOAD21',
          destination: destination2,
          timestamp: DateTime.now().toUtc());
      id = await repo.addPayloadRecordAsync(record21);
      expect(id, 3);
      expect((await repo.getPayloadRecordsAsync()).length, ++recordsCount);
      expect(
          (await repo.getPayloadRecordsWithDestinationIDAsync(
                  destination2.id ?? 0))
              .length,
          ++destination2RecordsCount);

      final record22 = PayloadRecord(
          configJson: 'CONFIG2',
          payloadJson: 'PAYLOAD22',
          destination: destination2,
          timestamp: DateTime.now().toUtc());
      id = await repo.addPayloadRecordAsync(record22);
      expect(id, 4);
      expect((await repo.getPayloadRecordsAsync()).length, ++recordsCount);
      expect(
          (await repo.getPayloadRecordsWithDestinationIDAsync(
                  destination2.id ?? 0))
              .length,
          ++destination2RecordsCount);

      await repo.removePayloadRecordAsync(record22);
      expect((await repo.getPayloadRecordsAsync()).length, --recordsCount);
      expect(
          (await repo.getPayloadRecordsWithDestinationIDAsync(
                  destination2.id ?? 0))
              .length,
          --destination2RecordsCount);

      await repo.removePayloadRecordAsync(record21);
      expect((await repo.getPayloadRecordsAsync()).length, --recordsCount);
      expect(
          (await repo.getPayloadRecordsWithDestinationIDAsync(
                  destination2.id ?? 0))
              .length,
          --destination2RecordsCount);

      expect((await repo.getPayloadRecordsAsync()).isNotEmpty, true);
      await repo.removePayloadRecordsOlderThanAsync(DateTime.now().toUtc());
      expect((await repo.getPayloadRecordsAsync()).length, 0);

      // verify that we can delete unused destinations:
      await repo.removeUnusedDestinationsAsync();
      expect((await repo.getDestinationsAsync()).length, 0);
    });
  });
}

void _cleanup() {
  var dbFile = File(DbDataAccess.dbFileName);
  if (dbFile.existsSync()) {
    dbFile.deleteSync();
  }
}
