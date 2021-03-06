import 'package:test/test.dart';

import 'package:rollbar_dart/rollbar.dart';

void main() {
  group('Live Rollbar tests:', () {
    setUp(() async {
      final config = Config(
          accessToken: '17965fa5041749b6bf7095a190001ded',
          package: 'rollbar_dart_example');

      await Rollbar.run(config);
    });

    tearDown(() {});

    test('basic test', () async {
      await Rollbar.message('Rollbar Flutter live test', level: Level.critical);
      await Future.delayed(Duration(milliseconds: 500));
    });
  });
}
