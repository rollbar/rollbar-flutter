import 'dart:io';

import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:rollbar_dart/src/notifier/notifier.dart';
import 'package:test/test.dart';

void main() {
  group('Notifier tests', () {
    test('Notifier version should match package version', () async {
      // Tests run from the current package dir, so we just read pubspec.yaml
      final pubspec = await File('pubspec.yaml') //
          .readAsString()
          .then(Pubspec.parse);
      expect(Notifier.version, equals(pubspec.version.toString()));
      expect(Notifier.name, equals('rollbar-dart'));
    });
  });
}
