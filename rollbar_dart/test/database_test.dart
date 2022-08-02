import 'dart:io';

import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:rollbar_dart/src/notifier/async_notifier.dart';
import 'package:rollbar_dart/rollbar.dart';

Future<void> main() async {
  late MockSender sender;

  group('Database tests', () {
    setUp(() async {
      sender = MockSender();
      when(sender.send(any)).thenAnswer((_) async => true);
    });

    tearDown(() {});

    test('Persistent database', () async {
      const databaseFilename = 'rollbar.db';

      final file = File(databaseFilename);
      if (file.existsSync()) file.deleteSync();
      expect(file.existsSync(), false);

      await Rollbar.run(Config(
          accessToken: 'SomeAccessToken',
          notifier: AsyncNotifier.new,
          persistPayloads: true));

      expect(file.existsSync(), true);
      file.deleteSync();
      expect(file.existsSync(), false);
    });

    test('In-memory database', () async {
      const databaseFilename = 'rollbar.db';

      final file = File(databaseFilename);
      if (file.existsSync()) file.deleteSync();
      expect(file.existsSync(), false);

      await Rollbar.run(Config(
          accessToken: 'SomeAccessToken',
          notifier: AsyncNotifier.new,
          persistPayloads: false));

      expect(file.existsSync(), false);
    });
  });
}

class MockSender extends Mock implements Sender {
  @override
  Future<bool> send(Map<String, dynamic>? payload) async {
    return super.noSuchMethod(
      Invocation.method(#send, [payload]),
      returnValue: Future<bool>.value(true),
    );
  }
}
