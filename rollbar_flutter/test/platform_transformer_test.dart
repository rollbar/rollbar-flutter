import 'package:flutter_test/flutter_test.dart';
import 'package:rollbar_dart/rollbar.dart';
import 'package:rollbar_dart/src/platform.dart';
import 'package:rollbar_flutter/src/platform_transformer.dart';

import 'platform_exception_utils.dart';

void main() {
  group('PlatformTransformer tests', () {
    String expectedMessage;

    setUp(() {
      RollbarPlatformInfo.isAndroid = true;
      expectedMessage = 'PlatformException(error, "Invalid counter state: 1")';
    });

    tearDown(() {
      RollbarPlatformInfo.reset();
    });

    group('Platform transformer (appendToChain: true)', () {
      PlatformTransformer transformer;

      setUp(() {
        transformer = PlatformTransformer(appendToChain: true);
      });

      test(
          'If error is PlatformException object with chain it should enrich trace chain',
          () async {
        var exception = createAndroidPlatformException(
            topFrameMethod: 'letsSeeYouParseThis', includeLineNumber: false);

        var frames = [Frame()..method = 'testThis', Frame()..method = 'what'];
        var body = createPlatformTraceInfo(exception, frames);

        var original = Data()..body = body;

        var updated =
            await transformer.transform(exception, StackTrace.empty, original);

        var traces = updated.body.getTraces();
        expect(traces, hasLength(2));

        var rootCause = traces[0];
        expect(rootCause.frames.length, greaterThan(1));
        expect(rootCause.frames[0].method, equals('letsSeeYouParseThis'));

        var dartTrace = traces[1];
        expect(dartTrace.frames, hasLength(2));
        expect(dartTrace.frames[0].method, equals('testThis'));
        expect(dartTrace.frames[1].method, equals('what'));

        // The message was temporarily hijacked to transfer the platform payload, let's make sure
        // it's been restored
        expect(dartTrace.exception.message, equals(expectedMessage));
      });

      test(
          'If error is PlatformException object with trace it should create chain',
          () async {
        var exception = createAndroidPlatformException(
            topFrameMethod: 'thisWillBeRethrown',
            includeLineNumber: true,
            createChain: true);

        var frames = [
          Frame()
            ..lineno = 3
            ..method = 'onTheDartSide'
        ];

        var body = createPlatformTraceInfo(exception, frames);
        var original = Data()..body = body;

        var updated =
            await transformer.transform(exception, StackTrace.empty, original);

        var traces = updated.body.getTraces();
        expect(traces, hasLength(3));

        var rootCause = traces[0];
        expect(rootCause.frames.length, greaterThan(1));
        expect(rootCause.frames[0].method, equals('thisWillBeRethrown'));

        var rethrownTrace = traces[1];
        expect(rethrownTrace.frames, hasLength(2));
        expect(rethrownTrace.frames[0].method, equals('processError'));
        expect(rethrownTrace.frames[1].method, equals('catchAndThrow'));

        var dartTrace = traces[2];
        expect(dartTrace.frames, hasLength(1));
        expect(dartTrace.frames[0].method, equals('onTheDartSide'));

        expect(dartTrace.exception.message, equals(expectedMessage));
      });
    });

    group('Platform transformer (appendToChain: false)', () {
      PlatformTransformer transformer;

      setUp(() {
        transformer = PlatformTransformer(appendToChain: false);
      });

      test(
          'If error is PlatformException object with chain it should attach platform payload',
          () async {
        var exception = createAndroidPlatformException(
            topFrameMethod: 'toBeAttached', includeLineNumber: true);

        var frames = [Frame()..method = 'thisFails'];

        var body = createPlatformTraceInfo(exception, frames);
        var original = Data()..body = body;

        var updated =
            await transformer.transform(exception, StackTrace.empty, original);

        var traces = updated.body.getTraces();
        expect(traces, hasLength(1));

        var dartTrace = traces[0];
        expect(dartTrace.frames, hasLength(1));
        expect(dartTrace.frames[0].method, equals('thisFails'));

        expect(dartTrace.exception.message, equals(expectedMessage));

        expect(updated.platformPayload, isNotNull);
        expect(updated.platformPayload['data']['notifier']['name'],
            equals('rollbar-java'));
        var trace = updated.platformPayload['data']['body']['trace'];
        expect(trace['frames'].length, equals(2));
        expect(trace['frames'][0]['method'], equals('toBeAttached'));
      });

      test(
          'If error is PlatformException object with trace it should attach platform payload',
          () async {
        var exception = createAndroidPlatformException(
            topFrameMethod: 'topChainFailure',
            includeLineNumber: true,
            createChain: true);

        var frames = [
          Frame()
            ..lineno = 3
            ..method = 'attachedFailureChain'
        ];

        var body = createPlatformTraceInfo(exception, frames);
        var original = Data()..body = body;

        var updated =
            await transformer.transform(exception, StackTrace.empty, original);

        var traces = updated.body.getTraces();
        expect(traces, hasLength(1));

        var dartTrace = traces[0];
        expect(dartTrace.frames, hasLength(1));
        expect(dartTrace.frames[0].method, equals('attachedFailureChain'));

        expect(dartTrace.exception.message, equals(expectedMessage));

        expect(updated.platformPayload, isNotNull);
        expect(updated.platformPayload['data']['notifier']['name'],
            equals('rollbar-java'));

        var chain = updated.platformPayload['data']['body']['trace_chain'];
        expect(chain.length, equals(2));

        var topTrace = chain[0];
        expect(topTrace['frames'][0]['method'], equals('topChainFailure'));
      });
    });
  });
}

TraceInfo createPlatformTraceInfo(Exception exception, List<Frame> frames) {
  return TraceInfo()
    ..exception = (ExceptionInfo()
      ..clazz = 'PlatformException'
      ..message = exception.toString())
    ..frames = frames;
}
