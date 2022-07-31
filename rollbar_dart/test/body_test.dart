import 'dart:convert';

import 'package:rollbar_dart/src/data/payload/body.dart';
import 'package:rollbar_dart/src/data/payload/exception_info.dart';
import 'package:rollbar_dart/src/data/payload/frame.dart';
import 'package:test/test.dart';

void main() {
  group('Serialization tests', () {
    test('Trace json roundtrip serialization test', () {
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

      final trace = Trace(
        rawTrace: 'stack frame 1 2 3',
        frames: frames,
        exception: ExceptionInfo(
          type: 'TestException',
          message: 'Attempted to test some code',
        ),
      );

      final asJson = jsonEncode(trace.toMap());
      final t = Trace.fromMap(jsonDecode(asJson));
      expect(t.exception.type, equals('TestException'));
      expect(t.exception.message, equals('Attempted to test some code'));
      expect(t.frames.length, equals(2));
      expect(t.rawTrace, equals('stack frame 1 2 3'));
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
        Trace(
            frames: frames,
            exception: ExceptionInfo(
              type: 'TestException',
              message: 'Attempted to test some code',
            )),
        Trace(
            frames: [frames[1]],
            exception: ExceptionInfo(
              type: 'TestException',
              message: 'Attempted to test some code',
            ))
      ];

      final asJson = jsonEncode(Traces(traces).toMap());
      final ts = Traces.fromMap(jsonDecode(asJson));
      expect(ts.traces.length, equals(2));
      expect(ts.traces.elementAt(0).frames.length, equals(2));
      expect(ts.traces.elementAt(0).frames.first.method, equals('inAChain'));
      expect(ts.traces.elementAt(1).frames.length, equals(1));
      expect(
          ts.traces.elementAt(1).frames.first.method, equals('_AnotherMethod'));
    });

    test('Message json roundtrip serialization test', () {
      const message = Message('This is a test message');
      final asJson = jsonEncode(message.toMap());
      final recovered = Message.fromMap(jsonDecode(asJson));
      expect(recovered.text, equals('This is a test message'));
    });
  });
}
