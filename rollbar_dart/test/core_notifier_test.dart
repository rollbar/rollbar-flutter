import 'dart:io';

import 'package:rollbar_dart/src/core_notifier.dart';
import 'package:test/test.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

void main() {
  group('Core notifier tests', () {
    test('Notifier version should match package version', () async {
      // Dart tests run from the current package directory, so we can just read pubspec.yaml
      var pubspecYaml = await File('pubspec.yaml').readAsString();
      var pubspec = Pubspec.parse(pubspecYaml);
      expect(CoreNotifier.notifierVersion, equals(pubspec.version.toString()));
    });
  });
}
