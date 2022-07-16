import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rollbar_dart/rollbar.dart';
import 'package:rollbar_flutter/src/platform_transformer.dart';

import 'utils/payload_utils.dart';
import 'utils/platform_exception_utils.dart';

void main() {
  group('PlatformTransformer tests', () {
    const filename = 'test/platform_transformer_test.dart';
    String? expectedMessage;

    setUp(() {
      expectedMessage = 'PlatformException(error, "Invalid counter state: 1")';
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    group('Platform transformer (appendToChain: true)', () {
      late PlatformTransformer transformer;

      setUp(() {
        transformer = PlatformTransformer(appendToChain: true);
      });

      test('Enrich trace chain on PlatformException', () async {
        final exception = androidPlatformException(
          topFrameMethod: 'letsSeeYouParseThis',
          includeLineNumber: false,
        );

        const frames = [
          Frame(filename: filename, method: 'testThis'),
          Frame(filename: filename, method: 'what'),
        ];

        final body = platformTraceInfo(exception, frames);
        final original = data(body: body);
        final transformed = await transformer.transform(
          exception,
          StackTrace.empty,
          original,
        );

        final traces = transformed.body.traces;
        expect(traces, hasLength(2));

        final dartTrace = traces[1];
        expect(dartTrace.frames, hasLength(2));
        expect(dartTrace.frames[0].method, equals('testThis'));
        expect(dartTrace.frames[1].method, equals('what'));

        // The message was temporarily hijacked to transfer the platform
        // payload, let's make sure it's been restored
        expect(dartTrace.exception.message, equals(expectedMessage));
      });

      test('Create chain on PlatformException with trace', () async {
        final exception = androidPlatformException(
          topFrameMethod: 'thisWillBeRethrown',
          includeLineNumber: true,
          createChain: true,
        );

        const frames = [
          Frame(filename: filename, method: 'onTheDartSide', line: 3)
        ];

        final body = platformTraceInfo(exception, frames);
        final original = data(body: body);
        final transformed =
            await transformer.transform(exception, StackTrace.empty, original);

        final traces = transformed.body.traces;
        expect(traces, hasLength(3));

        final rootCause = traces.first;
        expect(rootCause.frames.length, greaterThan(1));
        expect(rootCause.frames.first.method, equals('thisWillBeRethrown'));

        final rethrownTrace = traces[1];
        expect(rethrownTrace.frames, hasLength(2));
        expect(rethrownTrace.frames[0].method, equals('processError'));
        expect(rethrownTrace.frames[1].method, equals('catchAndThrow'));

        final dartTrace = traces[2];
        expect(dartTrace.frames, hasLength(1));
        expect(dartTrace.frames.first.method, equals('onTheDartSide'));

        expect(dartTrace.exception.message, equals(expectedMessage));
      });
    });

    group('Platform transformer (appendToChain: false)', () {
      late PlatformTransformer transformer;

      setUp(() {
        transformer = PlatformTransformer(appendToChain: false);
      });

      test('Attach platform payload on PlatformException with chain', () async {
        final exception = androidPlatformException(
          topFrameMethod: 'toBeAttached',
          includeLineNumber: true,
        );

        const frames = [Frame(filename: filename, method: 'thisFails')];

        final body = platformTraceInfo(exception, frames);
        final original = data(body: body);
        final transformed =
            await transformer.transform(exception, StackTrace.empty, original);

        final traces = transformed.body.traces;
        expect(traces, hasLength(1));

        final dartTrace = traces.first;
        expect(dartTrace.frames, hasLength(1));
        expect(dartTrace.frames.first.method, equals('thisFails'));

        expect(dartTrace.exception.message, equals(expectedMessage));

        expect(transformed.platformPayload, isNotNull);
        expect(transformed.platformPayload?['data']['notifier']['name'],
            equals('rollbar-java'));

        final trace = transformed.platformPayload?['data']['body']['trace'];
        expect(trace['frames'].length, equals(2));
        expect(trace['frames'][0]['method'], equals('toBeAttached'));
      });

      test('Attach platform payload on PlatformException with trace', () async {
        final exception = androidPlatformException(
          topFrameMethod: 'topChainFailure',
          includeLineNumber: true,
          createChain: true,
        );

        const frames = [
          Frame(filename: filename, method: 'attachedFailureChain', line: 3)
        ];

        final body = platformTraceInfo(exception, frames);
        final original = data(body: body);
        final transformed =
            await transformer.transform(exception, StackTrace.empty, original);

        final traces = transformed.body.traces;
        expect(traces, hasLength(1));

        final dartTrace = traces.first;
        expect(dartTrace.frames, hasLength(1));
        expect(dartTrace.frames.first.method, equals('attachedFailureChain'));

        expect(dartTrace.exception.message, equals(expectedMessage));

        expect(transformed.platformPayload, isNotNull);
        expect(transformed.platformPayload?['data']['notifier']['name'],
            equals('rollbar-java'));

        final chain =
            transformed.platformPayload?['data']['body']['trace_chain'];
        expect(chain.length, equals(2));

        final topTrace = chain.first;
        expect(topTrace['frames'][0]['method'], equals('topChainFailure'));
      });
    });
  });
}
