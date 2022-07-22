import 'dart:core';
import 'package:test/test.dart';
import 'package:rollbar_dart/src/ext/date_time.dart';

void main() {
  group('DateTime Extensions', () {
    test('DateTime comparison operators', () async {
      final past = DateTime(0x00);
      final now = DateTime.now();
      final future = DateTime(0x1EB208C2DC0000);

      expect(now > past, isTrue);
      expect(now < past, isFalse);
      expect(now >= past, isTrue);
      expect(now <= past, isFalse);

      expect(now > future, isFalse);
      expect(now < future, isTrue);
      expect(now >= future, isFalse);
      expect(now <= future, isTrue);

      expect(now > now, isFalse);
      expect(now < now, isFalse);
      expect(now <= now, isTrue);
      expect(now >= now, isTrue);
    });
  });
}
