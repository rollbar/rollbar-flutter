import 'dart:io';

import 'package:test/test.dart';

import 'package:rollbar_dart/src/payload_repository/destination.dart';
import 'package:rollbar_dart/src/payload_repository/payload_record.dart';
import 'package:rollbar_dart/src/payload_repository/payload_repository.dart';

void main() {
  group('Payload Repository:', () {
    const databaseFilename = 'rollbar_payloads.db';

    setUp(() {
      final file = File(databaseFilename);
      if (file.existsSync()) file.deleteSync();
    });

    tearDown(() {
      final file = File(databaseFilename);
      if (file.existsSync()) file.deleteSync();
    });

    test('Persistent vs non-persistent repository...', () async {
      final file = File(databaseFilename);
      expect(file.existsSync(), false);

      PayloadRepository(persistent: false);
      expect(file.existsSync(), false);

      PayloadRepository(persistent: true);
      expect(file.existsSync(), true);
    });

    test('Basic Destination entities manipulation...', () async {
      final repo = PayloadRepository(persistent: false);
      expect(repo.destinations.length, 0);

      // insert new destination:
      final destination =
          Destination(endpoint: 'wwww.site.com', accessToken: 'TOKEN1');
      repo.addDestination(destination);
      expect(repo.destination(id: destination.id), isNotNull);

      // refuses to insert the same destination more than once:
      expect(() async => repo.addDestination(destination), throwsException);

      // insert another destination:
      final destination2 =
          Destination(endpoint: 'wwww.site.com', accessToken: 'TOKEN2');
      repo.addDestination(destination2);
      expect(repo.destination(id: destination2.id), isNotNull);

      // refuses to insert similar destination:
      final destination3 =
          Destination(endpoint: 'wwww.site.com', accessToken: 'TOKEN2');
      expect(() async => repo.addDestination(destination3), throwsException);

      // verify total count of inserted destinations:
      expect(repo.destinations.length, 2);

      // verify that we can delete unused destinations:
      repo.removeUnusedDestinations();
      expect(repo.destinations.length, 0);
    });

    test('Basic PayloadRecord entities manipulation...', () async {
      final repo = PayloadRepository(persistent: false);
      expect(repo.destinations.length, 0);
      expect(repo.payloadRecords.length, 0);

      // insert new destination:
      final destination1 =
          Destination(endpoint: 'wwww.site.com', accessToken: 'TOKEN1');
      repo.addDestination(destination1);
      expect(repo.destination(id: destination1.id), isNotNull);

      // insert another destination:
      final destination2 =
          Destination(endpoint: 'wwww.site.com', accessToken: 'TOKEN2');
      repo.addDestination(destination2);
      expect(repo.destination(id: destination2.id), isNotNull);

      int recordsCount = 0;
      int destination1RecordsCount = 0;
      int destination2RecordsCount = 0;
      expect(repo.payloadRecords.length, recordsCount);
      expect(repo.getPayloadRecordsWithDestinationID(destination1.id).length,
          destination1RecordsCount);
      expect(repo.getPayloadRecordsWithDestinationID(destination2.id).length,
          destination2RecordsCount);

      final record11 = PayloadRecord(
          configJson: 'CONFIG1',
          payloadJson: 'PAYLOAD1',
          destination: destination1,
          timestamp: DateTime.now().toUtc());
      repo.addPayloadRecord(record11);
      expect(repo.payloadRecord(id: record11.id), isNotNull);
      expect(repo.payloadRecords.length, ++recordsCount);
      expect(repo.getPayloadRecordsWithDestinationID(destination1.id).length,
          ++destination1RecordsCount);

      final record12 = PayloadRecord(
          configJson: 'CONFIG1',
          payloadJson: 'PAYLOAD1',
          destination: destination1,
          timestamp: DateTime.now().toUtc());
      repo.addPayloadRecord(record12);
      expect(repo.payloadRecord(id: record12.id), isNotNull);
      expect(repo.payloadRecords.length, ++recordsCount);
      expect(repo.getPayloadRecordsWithDestinationID(destination1.id).length,
          ++destination1RecordsCount);

      final record21 = PayloadRecord(
          configJson: 'CONFIG2',
          payloadJson: 'PAYLOAD21',
          destination: destination2,
          timestamp: DateTime.now().toUtc());
      repo.addPayloadRecord(record21);
      expect(repo.payloadRecord(id: record21.id), isNotNull);
      expect(repo.payloadRecords.length, ++recordsCount);
      expect(repo.getPayloadRecordsWithDestinationID(destination2.id).length,
          ++destination2RecordsCount);

      final record22 = PayloadRecord(
          configJson: 'CONFIG2',
          payloadJson: 'PAYLOAD22',
          destination: destination2,
          timestamp: DateTime.now().toUtc());
      repo.addPayloadRecord(record22);
      expect(repo.payloadRecord(id: record22.id), isNotNull);
      expect(repo.payloadRecords.length, ++recordsCount);
      expect(repo.getPayloadRecordsWithDestinationID(destination2.id).length,
          ++destination2RecordsCount);

      repo.removePayloadRecord(record22);
      expect(repo.payloadRecords.length, --recordsCount);
      expect(repo.getPayloadRecordsWithDestinationID(destination2.id).length,
          --destination2RecordsCount);

      repo.removePayloadRecord(record21);
      expect(repo.payloadRecords.length, --recordsCount);
      expect(repo.getPayloadRecordsWithDestinationID(destination2.id).length,
          --destination2RecordsCount);

      expect(repo.payloadRecords.isNotEmpty, true);
      repo.removePayloadRecordsOlderThan(DateTime.now().toUtc());
      expect(repo.payloadRecords.length, 0);

      // verify that we can delete unused destinations:
      repo.removeUnusedDestinations();
      expect(repo.destinations.length, 0);
    });
  });
}
