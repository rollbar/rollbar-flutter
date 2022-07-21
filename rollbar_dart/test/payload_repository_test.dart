import 'dart:io';

import 'package:test/test.dart';

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

    test('Basic PayloadRecord entities manipulation...', () async {
      final repo = PayloadRepository(persistent: false);
      expect(repo.payloadRecords.length, 0);

      int recordsCount = 0;
      expect(repo.payloadRecords.length, recordsCount);

      final record11 = PayloadRecord(
          accessToken: 'TOKEN1',
          endpoint: 'wwww.site.com',
          configJson: 'CONFIG1',
          payloadJson: 'PAYLOAD1',
          timestamp: DateTime.now().toUtc());
      repo.addPayloadRecord(record11);
      expect(repo.payloadRecord(id: record11.id), isNotNull);
      expect(repo.payloadRecords.length, ++recordsCount);

      final record12 = PayloadRecord(
          accessToken: 'TOKEN1',
          endpoint: 'wwww.site.com',
          configJson: 'CONFIG1',
          payloadJson: 'PAYLOAD12',
          timestamp: DateTime.now().toUtc());
      repo.addPayloadRecord(record12);
      expect(repo.payloadRecord(id: record12.id), isNotNull);
      expect(repo.payloadRecords.length, ++recordsCount);

      final record21 = PayloadRecord(
          accessToken: 'TOKEN2',
          endpoint: 'wwww.site.com',
          configJson: 'CONFIG2',
          payloadJson: 'PAYLOAD21',
          timestamp: DateTime.now().toUtc());
      repo.addPayloadRecord(record21);
      expect(repo.payloadRecord(id: record21.id), isNotNull);
      expect(repo.payloadRecords.length, ++recordsCount);

      final record22 = PayloadRecord(
          accessToken: 'TOKEN2',
          endpoint: 'wwww.site.com',
          configJson: 'CONFIG2',
          payloadJson: 'PAYLOAD22',
          timestamp: DateTime.now().toUtc());
      repo.addPayloadRecord(record22);
      expect(repo.payloadRecord(id: record22.id), isNotNull);
      expect(repo.payloadRecords.length, ++recordsCount);

      repo.removePayloadRecord(id: record22.id);
      expect(repo.payloadRecords.length, --recordsCount);

      repo.removePayloadRecord(id: record21.id);
      expect(repo.payloadRecords.length, --recordsCount);

      expect(repo.payloadRecords.isNotEmpty, true);
      repo.removePayloadRecordsOlderThan(DateTime.now().toUtc());
      expect(repo.payloadRecords.length, 0);
    });
  });
}
