import 'dart:io';
import 'dart:math';

import 'package:test/test.dart';

import 'package:rollbar_dart/src/ext/math.dart';
import 'package:rollbar_dart/src/ext/collection.dart' as f;
import 'package:rollbar_dart/src/data/payload_record.dart';
import 'package:rollbar_dart/src/payload_record_database.dart';

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

    test('Persistent vs non-persistent repository', () async {
      final file = File(databaseFilename);
      expect(file.existsSync(), false);

      PayloadRecordDatabase();
      expect(file.existsSync(), false);

      PayloadRecordDatabase(isPersistent: true);
      expect(file.existsSync(), true);
    });

    test('Basic PayloadRecord entities manipulation', () async {
      final payloadRecords = PayloadRecordDatabase();
      expect(payloadRecords.length, 0);

      int recordsCount = 0;
      expect(payloadRecords.length, recordsCount);

      final record11 = PayloadRecord(
          accessToken: 'TOKEN1',
          endpoint: 'wwww.site.com',
          config: 'CONFIG1',
          payload: 'PAYLOAD1');
      payloadRecords.add(record11);
      expect(payloadRecords.record(id: record11.id), isNotNull);
      expect(payloadRecords.length, ++recordsCount);

      final record12 = PayloadRecord(
          accessToken: 'TOKEN1',
          endpoint: 'wwww.site.com',
          config: 'CONFIG1',
          payload: 'PAYLOAD12');
      payloadRecords.add(record12);
      expect(payloadRecords.record(id: record12.id), isNotNull);
      expect(payloadRecords.length, ++recordsCount);

      final record21 = PayloadRecord(
          accessToken: 'TOKEN2',
          endpoint: 'wwww.site.com',
          config: 'CONFIG2',
          payload: 'PAYLOAD21');
      payloadRecords.add(record21);
      expect(payloadRecords.record(id: record21.id), isNotNull);
      expect(payloadRecords.length, ++recordsCount);

      final record22 = PayloadRecord(
          accessToken: 'TOKEN2',
          endpoint: 'wwww.site.com',
          config: 'CONFIG2',
          payload: 'PAYLOAD22');
      payloadRecords.add(record22);
      expect(payloadRecords.record(id: record22.id), isNotNull);
      expect(payloadRecords.length, ++recordsCount);

      final result = payloadRecords.remove(record22);
      expect(result, isTrue);
      expect(payloadRecords.length, --recordsCount);

      payloadRecords.remove(record21);
      expect(payloadRecords.length, --recordsCount);

      expect(payloadRecords.isNotEmpty, true);
      payloadRecords.removeOlderThan(DateTime.now().toUtc());
      expect(payloadRecords.length, 0);
    });

    test('PayloadRepository database adds records correctly', () async {
      final payloadRecords = PayloadRecordDatabase();
      final record = PayloadRecord(
          accessToken: 'TOKEN1',
          endpoint: 'wwww.site.com',
          config: 'CONFIG1',
          payload: 'PAYLOAD1');

      payloadRecords.add(record);
      expect(payloadRecords.isNotEmpty, isTrue);
      expect(payloadRecords.length, 1);
      expect(payloadRecords.contains(record), isTrue);

      final first = payloadRecords.first;
      expect(first, equals(record));
      expect(first.id, equals(record.id));
      expect(first.accessToken, equals(record.accessToken));
      expect(first.endpoint, equals(record.endpoint));
      expect(first.config, equals(record.config));
      expect(first.payload, equals(record.payload));
      expect(first.timestamp, equals(record.timestamp));

      final other = payloadRecords.record(id: record.id);
      expect(other, isNotNull);
      expect(other, equals(record));
      expect(other?.id, equals(record.id));
      expect(other?.accessToken, equals(record.accessToken));
      expect(other?.endpoint, equals(record.endpoint));
      expect(other?.config, equals(record.config));
      expect(other?.payload, equals(record.payload));
      expect(other?.timestamp, equals(record.timestamp));

      final another = payloadRecords.lookup(record);
      expect(another, isNotNull);
      expect(another, equals(record));
      expect(another?.id, equals(record.id));
      expect(another?.accessToken, equals(record.accessToken));
      expect(another?.endpoint, equals(record.endpoint));
      expect(another?.config, equals(record.config));
      expect(another?.payload, equals(record.payload));
      expect(another?.timestamp, equals(record.timestamp));
    });

    test('PayloadRepository database doesn\'t accept duplicates', () async {
      final payloadRecords = PayloadRecordDatabase();
      final record = PayloadRecord(
          accessToken: 'TOKEN1',
          endpoint: 'wwww.site.com',
          config: 'CONFIG1',
          payload: 'PAYLOAD1');

      final result1 = payloadRecords.add(record);
      expect(result1, isTrue);
      expect(payloadRecords.length, 1);
      expect(payloadRecords.isNotEmpty, isTrue);
      expect(payloadRecords.contains(record), isTrue);

      final result2 = payloadRecords.add(record);
      expect(result2, isFalse);
      expect(payloadRecords.length, 1);
      expect(payloadRecords.isNotEmpty, isTrue);
      expect(payloadRecords.contains(record), isTrue);
    });

    test('PayloadRepository database removes records correctly', () async {
      final payloadRecords = PayloadRecordDatabase();
      final record = PayloadRecord(
          accessToken: 'TOKEN1',
          endpoint: 'wwww.site.com',
          config: 'CONFIG1',
          payload: 'PAYLOAD1');

      expect(payloadRecords.add(record), isTrue);

      final result = payloadRecords.remove(record);
      expect(result, isTrue);
      expect(payloadRecords.length, 0);
      expect(payloadRecords.isEmpty, isTrue);
      expect(payloadRecords.contains(record), isFalse);
    });

    test('PayloadRepository database is iterable', () async {
      final findableRecord = Record.generate().copyWith(accessToken: '1234');
      final payloadRecords = PayloadRecordDatabase();
      final records = Iterable.generate(
        16,
        (i) => i == 5 ? findableRecord : Record.generate(),
      ).toSet();

      records.forEach(payloadRecords.add);
      expect(payloadRecords.length, 16);
      expect(payloadRecords.map(records.contains).any(f.isFalse), isFalse);

      for (final record in payloadRecords) {
        expect(records.contains(record), isTrue);
      }

      final record =
          payloadRecords.firstWhere((record) => record.accessToken == '1234');
      expect(record, equals(findableRecord));
    });

    test('PayloadRepository database conforms to Set', () async {
      final payloadRecords = PayloadRecordDatabase();
      [
        Record.generate(),
        Record.generate(),
        Record.generate().copyWith(accessToken: '1234'),
        Record.generate(),
        Record.generate().copyWith(accessToken: '1234'),
        Record.generate()
      ].forEach(payloadRecords.add);
      expect(payloadRecords.length, equals(6));

      payloadRecords.removeWhere((r) => r.accessToken == '1234');
      expect(payloadRecords.length, equals(4));
      expect(payloadRecords.any((r) => r.accessToken == '1234'), isFalse);

      final newestRecords = {
        Record.generate().copyWith(accessToken: '1234'),
        Record.generate().copyWith(accessToken: '1234')
      };

      payloadRecords.addAll(newestRecords);
      expect(payloadRecords.length, equals(6));

      payloadRecords.retainWhere((r) => r.accessToken == '1234');
      expect(payloadRecords.length, equals(2));
      expect(payloadRecords.all((r) => r.accessToken == '1234'), isTrue);

      final newRecords = Iterable.generate(4, (_) => Record.generate()).toSet();
      final newDatabase = payloadRecords.union(newRecords);
      expect(newDatabase.length, equals(6));

      final newestDatabase = newDatabase.difference(newestRecords);
      expect(newestDatabase.length, equals(4));
      expect(newestDatabase.any((r) => r.accessToken == '1234'), isFalse);

      newDatabase.clear();
      expect(newestDatabase.isNotEmpty, isTrue);
      expect(payloadRecords.isNotEmpty, isTrue);

      newestDatabase.clear();
      expect(payloadRecords.isNotEmpty, isTrue);

      payloadRecords.clear();
      expect(newDatabase.isEmpty, isTrue);
      expect(newestDatabase.isEmpty, isTrue);
      expect(payloadRecords.isEmpty, isTrue);
    });
  });
}

extension Record on PayloadRecord {
  static final rnd = Random();

  static PayloadRecord generate() {
    return PayloadRecord(
        accessToken: rnd.nextString(32),
        endpoint: rnd.nextString(32),
        config: rnd.nextString(32),
        payload: rnd.nextString(32));
  }
}
