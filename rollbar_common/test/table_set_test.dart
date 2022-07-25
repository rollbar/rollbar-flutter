import 'dart:io';
import 'dart:math';

import 'package:rollbar_common/src/extension/function.dart';
import 'package:rollbar_common/src/extension/math.dart';
import 'package:rollbar_common/src/extension/collection.dart' as f;
import 'package:rollbar_common/src/persistable.dart';
import 'package:rollbar_common/src/record.dart';
import 'package:rollbar_common/src/table_set.dart';
import 'package:test/test.dart';

void main() {
  group('Datatype tests', () {
    test('Datatype sql type declaration is well formed', () {
      for (final datatype in Datatype.values) {
        final decl = datatype.sqlTypeDeclaration;
        switch (datatype) {
          case Datatype.uuid:
            return expect(decl, equals('BINARY(16) NOT NULL PRIMARY KEY'));
          case Datatype.integer:
            return expect(decl, equals('INTEGER NOT NULL'));
          case Datatype.real:
            return expect(decl, equals('REAL NOT NULL'));
          case Datatype.text:
            return expect(decl, equals('TEXT NOT NULL'));
          case Datatype.blob:
            return expect(decl, equals('BLOB NOT NULL'));
        }
      }
    });
  });

  group('TableSet tests', () {
    const databaseFilename = 'rollbar.db';

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

      TableSet<Record>();
      expect(file.existsSync(), false);

      TableSet<Record>(isPersistent: true);
      expect(file.existsSync(), true);
    });

    test('Adding and removing records', () async {
      final payloadRecords = TableSet<Record>();
      expect(payloadRecords.length, 0);

      int recordsCount = 0;
      expect(payloadRecords.length, recordsCount);

      for (final record in Iterable.generate(4, (_) => _Record.generate())) {
        expect(payloadRecords.add(record), isTrue);
        expect(payloadRecords.record(id: record.id), isNotNull);
        expect(payloadRecords.length, ++recordsCount);
      }

      for (final record in payloadRecords.map(identity)) {
        expect(payloadRecords.remove(record), isTrue);
        expect(payloadRecords.record(id: record.id), isNull);
        expect(payloadRecords.length, --recordsCount);
      }

      expect(payloadRecords.isEmpty, true);
    });

    test('Stored records preserve original data', () async {
      final payloadRecords = TableSet<Record>();
      final record = _Record.generate();

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

    test('Duplicates are ignored when adding', () async {
      final payloadRecords = TableSet<Record>();
      final record = _Record.generate();

      expect(payloadRecords.add(record), isTrue);
      expect(payloadRecords.length, 1);
      expect(payloadRecords.isNotEmpty, isTrue);
      expect(payloadRecords.contains(record), isTrue);

      expect(payloadRecords.add(record), isFalse);
      expect(payloadRecords.length, 1);
      expect(payloadRecords.isNotEmpty, isTrue);
      expect(payloadRecords.contains(record), isTrue);

      expect(payloadRecords.remove(record), isTrue);
      expect(payloadRecords.length, 0);
      expect(payloadRecords.isEmpty, isTrue);
      expect(payloadRecords.contains(record), isFalse);
    });

    test('Updates entries correctly', () async {
      final tableSet = TableSet<Record>();
      final record = _Record.generate();
      final oldConfig = record.config;

      expect(tableSet.update(record), isFalse);
      expect(tableSet.add(record), isTrue);
      expect(tableSet.any((record) => record.config == oldConfig), isTrue);

      final updated = tableSet.record(id: record.id)!.copyWith(config: '1234');
      expect(tableSet.update(updated), isTrue);
      expect(tableSet.any((record) => record.config == oldConfig), isFalse);
      expect(tableSet.any((record) => record.config == '1234'), isTrue);
    });

    test('PayloadRepository database is iterable', () async {
      final findableRecord = _Record.generate().copyWith(accessToken: '1234');
      final payloadRecords = TableSet<Record>();
      final records = Iterable.generate(
        16,
        (i) => i == 5 ? findableRecord : _Record.generate(),
      ).toSet();

      records.forEach(payloadRecords.add);
      expect(payloadRecords.length, 16);

      final transformResult = payloadRecords.map(records.contains);
      expect(transformResult.any(f.isFalse), isFalse);

      for (final record in payloadRecords) {
        expect(records.contains(record), isTrue);
      }

      final record =
          payloadRecords.firstWhere((record) => record.accessToken == '1234');
      expect(record, equals(findableRecord));
    });

    test('PayloadRepository database conforms to Set', () async {
      final payloadRecords = TableSet<Record>();
      [
        _Record.generate(),
        _Record.generate(),
        _Record.generate().copyWith(accessToken: '1234'),
        _Record.generate(),
        _Record.generate().copyWith(accessToken: '1234'),
        _Record.generate()
      ].forEach(payloadRecords.add);
      expect(payloadRecords.length, equals(6));

      payloadRecords.removeWhere((r) => r.accessToken == '1234');
      expect(payloadRecords.length, equals(4));
      expect(payloadRecords.any((r) => r.accessToken == '1234'), isFalse);

      final newestRecords = {
        _Record.generate().copyWith(accessToken: '1234'),
        _Record.generate().copyWith(accessToken: '1234')
      };

      payloadRecords.addAll(newestRecords);
      expect(payloadRecords.length, equals(6));

      payloadRecords.retainWhere((r) => r.accessToken == '1234');
      expect(payloadRecords.length, equals(2));
      expect(payloadRecords.all((r) => r.accessToken == '1234'), isTrue);

      final newRecords =
          Iterable.generate(4, (_) => _Record.generate()).toSet();
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

extension _Record on Record {
  static final rnd = Random();

  static Record generate() {
    return Record(
        accessToken: rnd.nextString(32),
        endpoint: rnd.nextString(32),
        config: rnd.nextString(32),
        payload: rnd.nextString(32));
  }
}
