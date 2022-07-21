import 'dart:io';

import 'package:rollbar_dart/src/core_notifier.dart';
import 'package:test/test.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

void main() {
  group('Core notifier tests', () {
    test('Notifier version should match package version', () async {
      // Tests run from the current package dir, so we just read pubspec.yaml
      final pubspecYaml = await File('pubspec.yaml').readAsString();
      final pubspec = Pubspec.parse(pubspecYaml);
      expect(CoreNotifier.version, equals(pubspec.version.toString()));
    });
  });
}
