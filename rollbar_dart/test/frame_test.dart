import 'dart:convert';

import 'package:rollbar_dart/src/api/payload/frame.dart';
import 'package:test/test.dart';

void main() {
  group('Serialization tests', () {
    test('Json roundtrip serialization test', () {
      final frame = Frame()
        ..className = 'ignore.this.Class'
        ..colno = 3
        ..filename = 'test.dart'
        ..lineno = 100
        ..method = 'someMethod';

      final asJson = jsonEncode(frame.toMap());
      final recovered = Frame.fromMap(jsonDecode(asJson));

      expect(recovered.className, equals(frame.className));
      expect(recovered.colno, equals(frame.colno));
      expect(recovered.filename, equals(frame.filename));
      expect(recovered.lineno, equals(frame.lineno));
      expect(recovered.method, equals(frame.method));
    });

    test('Serialization is null-safe test', () {
      final nullFrame = Frame();
      final asJson = jsonEncode(nullFrame.toMap());
      final recovered = Frame.fromMap(jsonDecode(asJson));

      expect(recovered.className, equals(nullFrame.className));
      expect(recovered.colno, equals(nullFrame.colno));
      expect(recovered.filename, equals(nullFrame.filename));
      expect(recovered.lineno, equals(nullFrame.lineno));
      expect(recovered.method, equals(nullFrame.method));
    });

    test('To Json conversion ignores null values test', () {
      final json = Frame().toMap();
      expect(json.containsKey('className'), false);
      expect(json.containsKey('method'), false);
      expect(json.containsKey('lineno'), false);
      expect(json.containsKey('colno'), false);
      expect(json.containsKey('filename'), false);
      expect(json.isEmpty, true);
    });
  });
}
