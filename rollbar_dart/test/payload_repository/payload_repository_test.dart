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

      await PayloadRepository.createInMemoryAsync()
          .then((value) => expect(dbFile.existsSync(), false));

      await PayloadRepository.createPersistentAsync()
          .then((value) => expect(dbFile.existsSync(), true));
    });

    test('Persistent vs non-persistent repository...', () async {
      final repo = await PayloadRepository.createInMemoryAsync();
      await repo
          .getDestinationsAsync()
          .then((value) => expect(value.length, 0));

      var destination =
          Destination.create(endpoint: 'wwww.site.com', accessToken: 'TOKEN1');

      // final id = await repo
      //     .addDestination(destination)
      //     .then((value) => expect(value > 0, true));
      // await repo.addDestination(destination).then((value) =>
      //     repo.getDestinations().then((value) => expect(value.length, 1)));
    });
  });
}

void _cleanup() {
  var dbFile = File(DbDataAccess.dbFileName);
  if (dbFile.existsSync()) {
    dbFile.deleteSync();
  }
}
