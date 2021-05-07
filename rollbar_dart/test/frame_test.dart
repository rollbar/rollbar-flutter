import 'dart:convert';

import 'package:rollbar_dart/src/api/payload/frame.dart';
import 'package:test/test.dart';

void main() {
  group('Serialization tests', () {
    test('Json roundtrip serialization test', () {
      var frame = Frame()
        ..className = 'ignore.this.Class'
        ..colno = 3
        ..filename = 'test.dart'
        ..lineno = 100
        ..method = 'someMethod';

      var asJson = jsonEncode(frame.toJson());
      var recovered = Frame.fromMap(jsonDecode(asJson));

      expect(recovered.className, equals(frame.className));
      expect(recovered.colno, equals(frame.colno));
      expect(recovered.filename, equals(frame.filename));
      expect(recovered.lineno, equals(frame.lineno));
      expect(recovered.method, equals(frame.method));
    });
  });
}
