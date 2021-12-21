import 'dart:convert';

import 'package:rollbar_dart/src/api/payload/body.dart';
import 'package:rollbar_dart/src/api/payload/exception_info.dart';
import 'package:rollbar_dart/src/api/payload/frame.dart';
import 'package:test/test.dart';

void main() {
  group('Serialization tests', () {
    test('TraceInfo json roundtrip serialization test', () {
      var frames = [
        Frame()
          ..className = 'ignore.this.Class'
          ..colno = 3
          ..filename = 'test.dart'
          ..lineno = 100
          ..method = 'someMethod',
        Frame()
          ..className = 'ignore.this.AsWell'
          ..filename = 'test2.dart'
          ..method = '_AnotherMethod'
      ];

      var traceInfo = TraceInfo()
        ..rawTrace = 'stack frame 1 2 3'
        ..frames = frames
        ..exception = (ExceptionInfo()
          ..clazz = 'TestException'
          ..message = 'Attempted to test some code');

      var asJson = jsonEncode(traceInfo.toJson());

      for (var builder in [
        (v) => TraceInfo.fromMap(v),
        (v) => Body.fromMap(v)
      ]) {
        var recovered = builder(jsonDecode(asJson)) as TraceInfo;

        expect(recovered.exception!.clazz, equals('TestException'));
        expect(recovered.exception!.message,
            equals('Attempted to test some code'));
        expect(recovered.frames.length, equals(2));
        expect(recovered.rawTrace, equals('stack frame 1 2 3'));
      }
    });

    test('TraceChain json roundtrip serialization test', () {
      var frames = [
        Frame()
          ..className = 'ignore.this.Class'
          ..colno = 3
          ..filename = 'test.dart'
          ..lineno = 100
          ..method = 'inAChain',
        Frame()
          ..className = 'ignore.this.AsWell'
          ..filename = 'test2.dart'
          ..method = '_AnotherMethod'
      ];

      var traceInfo1 = TraceInfo()
        ..frames = frames
        ..exception = (ExceptionInfo()
          ..clazz = 'TestException'
          ..message = 'Attempted to test some code');

      var traceInfo2 = TraceInfo()
        ..frames = [frames[1]]
        ..exception = (ExceptionInfo()
          ..clazz = 'TestException'
          ..message = 'Attempted to test some code');

      var chain = TraceChain()..traces = [traceInfo1, traceInfo2];
      var asJson = jsonEncode(chain.toJson());

      for (var builder in [
        (v) => TraceChain.fromMap(v),
        (v) => Body.fromMap(v)
      ]) {
        var recovered = builder(jsonDecode(asJson)) as TraceChain;

        expect(recovered.traces!.length, equals(2));
        expect(recovered.traces![0]!.frames.length, equals(2));
        expect(recovered.traces![0]!.frames[0].method, equals('inAChain'));

        expect(recovered.traces![1]!.frames.length, equals(1));
        expect(
            recovered.traces![1]!.frames[0].method, equals('_AnotherMethod'));
      }
    });

    test('Message json roundtrip serialization test', () {
      var message = Message()..body = 'This is a test body';

      var asJson = jsonEncode(message.toJson());

      for (var builder in [(v) => Message.fromMap(v), (v) => Body.fromMap(v)]) {
        var recovered = builder(jsonDecode(asJson)) as Message;

        expect(recovered.body, equals('This is a test body'));
      }
    });
  });
}
