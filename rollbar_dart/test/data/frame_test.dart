import 'dart:convert';

import 'package:rollbar_dart/src/data/payload/frame.dart';
import 'package:test/test.dart';

void main() {
  group('Frame serialization tests', () {
    test('Serialization is null-safe test', () {
      const nullFrame = Frame(filename: 'test.dart');
      final asJson = jsonEncode(nullFrame.toMap());
      final recovered = Frame.fromMap(jsonDecode(asJson));
      expect(recovered.filename, equals(nullFrame.filename));
      expect(recovered.type, equals(nullFrame.type));
      expect(recovered.method, equals(nullFrame.method));
      expect(recovered.line, equals(nullFrame.line));
      expect(recovered.column, equals(nullFrame.column));
    });

    test('To Json conversion ignores null values test', () {
      final json = Frame(filename: 'test.dart').toMap();
      expect(json.containsKey('filename'), true);
      expect(json.containsKey('className'), false);
      expect(json.containsKey('method'), false);
      expect(json.containsKey('lineno'), false);
      expect(json.containsKey('colno'), false);
    });

    test('String representation', () {
      const f0 = Frame(filename: 'test.dart');
      expect(f0.location, equals('test.dart'));
      expect(f0.member, '???');
      expect(f0.toString(), equals('Frame: ??? (test.dart)'));

      const f1 = Frame(filename: 'test.dart', type: 'Any');
      expect(f1.location, equals('test.dart'));
      expect(f1.member, 'Any.???');
      expect(f1.toString(), equals('Frame: Any.??? (test.dart)'));

      const f2 = Frame(filename: 'test.dart', method: 'freeFunction.<fn>');
      expect(f2.location, equals('test.dart'));
      expect(f2.member, 'freeFunction.<fn>');
      expect(f2.toString(), equals('Frame: freeFunction.<fn> (test.dart)'));

      const f3 = Frame(filename: 'test.dart', type: 'Any', method: 'func');
      expect(f3.location, equals('test.dart'));
      expect(f3.member, 'Any.func');
      expect(f3.toString(), equals('Frame: Any.func (test.dart)'));

      const f4 =
          Frame(filename: 'test.dart', type: 'Any', method: 'func', line: 20);
      expect(f4.location, equals('test.dart:20'));
      expect(f4.member, 'Any.func');
      expect(f4.toString(), equals('Frame: Any.func (test.dart:20)'));

      const f5 =
          Frame(filename: 'test.dart', type: 'Any', method: 'func', column: 3);
      expect(f5.location, equals('test.dart:???:3'));
      expect(f5.member, 'Any.func');
      expect(f5.toString(), equals('Frame: Any.func (test.dart:???:3)'));

      const f6 = Frame(
          filename: 't.dart', type: 'Any', method: 'func', line: 20, column: 3);
      expect(f6.location, equals('t.dart:20:3'));
      expect(f6.member, 'Any.func');
      expect(f6.toString(), equals('Frame: Any.func (t.dart:20:3)'));
    });
  });
}
