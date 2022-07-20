import 'dart:convert';

import 'package:rollbar_dart/src/api/payload/body.dart';
import 'package:rollbar_dart/src/api/payload/exception_info.dart';
import 'package:rollbar_dart/src/api/payload/frame.dart';
import 'package:test/test.dart';

void main() {
  group('Serialization tests', () {
    test('TraceInfo json roundtrip serialization test', () {
      const frames = [
        Frame(
            filename: 'test.dart',
            type: 'ignore.this.Class',
            method: 'someMethod',
            line: 100,
            column: 3),
        Frame(
            filename: 'test2.dart',
            type: 'ignore.this.AsWell',
            method: '_AnotherMethod')
      ];

      final traceInfo = TraceInfo(
        rawTrace: 'stack frame 1 2 3',
        frames: frames,
        exception: ExceptionInfo(
          type: 'TestException',
          message: 'Attempted to test some code',
        ),
      );

      final asJson = jsonEncode(traceInfo.toMap());

      for (final fromMap in [TraceInfo.fromMap, Body.fromMap]) {
        final ti = fromMap(jsonDecode(asJson)) as TraceInfo;
        expect(ti.exception.type, equals('TestException'));
        expect(ti.exception.message, equals('Attempted to test some code'));
        expect(ti.frames.length, equals(2));
        expect(ti.rawTrace, equals('stack frame 1 2 3'));
      }
    });

    test('TraceChain json roundtrip serialization test', () {
      const frames = [
        Frame(
            filename: 'test.dart',
            type: 'ignore.this.Class',
            method: 'inAChain',
            line: 100,
            column: 3),
        Frame(
            filename: 'test2.dart',
            type: 'ignore.this.AsWell',
            method: '_AnotherMethod')
      ];

      final traces = [
        TraceInfo(
            frames: frames,
            exception: ExceptionInfo(
              type: 'TestException',
              message: 'Attempted to test some code',
            )),
        TraceInfo(
            frames: [frames[1]],
            exception: ExceptionInfo(
              type: 'TestException',
              message: 'Attempted to test some code',
            ))
      ];

      final asJson = jsonEncode(TraceChain(traces).toMap());

      for (final fromMap in [TraceChain.fromMap, Body.fromMap]) {
        final tc = fromMap(jsonDecode(asJson)) as TraceChain;

        expect(tc.traces.length, equals(2));
        expect(tc.traces[0].frames.length, equals(2));
        expect(tc.traces[0].frames.first.method, equals('inAChain'));

        expect(tc.traces[1].frames.length, equals(1));
        expect(tc.traces[1].frames.first.method, equals('_AnotherMethod'));
      }
    });

    test('Message json roundtrip serialization test', () {
      const message = Message('This is a test message');
      final asJson = jsonEncode(message.toMap());

      for (final fromMap in [Message.fromMap, Body.fromMap]) {
        final recovered = fromMap(jsonDecode(asJson)) as Message;
        expect(recovered.text, equals('This is a test message'));
      }
    });
  });
}
