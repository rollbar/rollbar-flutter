import 'package:rollbar_dart/src/data/payload/level.dart';
import 'package:test/test.dart';

void main() {
  group('Level enum tests', () {
    test('Level name returns the correct name', () {
      for (final level in Level.values) {
        switch (level) {
          case Level.debug:
            expect(level.name, equals('debug'));
            break;
          case Level.info:
            expect(level.name, equals('info'));
            break;
          case Level.warning:
            expect(level.name, equals('warning'));
            break;
          case Level.error:
            expect(level.name, equals('error'));
            break;
          case Level.critical:
            expect(level.name, equals('critical'));
            break;
        }
      }
    });
  });
}
