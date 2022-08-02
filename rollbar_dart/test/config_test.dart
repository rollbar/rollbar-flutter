import 'dart:math';

import 'package:test/test.dart';
import 'package:rollbar_common/rollbar_common.dart' hide isTrue, isFalse;
import 'package:rollbar_dart/rollbar_dart.dart';

final rnd = Random();

void main() {
  group('Config tests', () {});

  test('Serialization uses camelCase for keys', () {
    expect(
        Config(accessToken: rnd.nextString(16))
            .toMap()
            .anyKey((k) => k.contains('_')),
        isFalse);
  });
}
