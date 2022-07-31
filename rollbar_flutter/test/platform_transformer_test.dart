import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:rollbar_dart/rollbar.dart';
import 'package:rollbar_flutter/src/platform_transformer.dart';

import 'platform_transformer_test.mocks.dart';
import 'utils/payload_utils.dart';
import 'utils/platform_exception_utils.dart';

@GenerateMocks([Telemetry])
void main() {
  group('PlatformTransformer tests', () {
    const filename = 'test/platform_transformer_test.dart';
    final telemetryMock = MockTelemetry();
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
        transformer = PlatformTransformer(append: true);
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

        final body = Body(report: platformTraceInfo(exception, frames));
        final original = dataFrom(body: body);
        final transformed = await transformer.transform(
          Event(
              error: exception,
              stackTrace: StackTrace.empty,
              telemetry: telemetryMock),
          original,
        );

        final traces = transformed.body.report.traces;
        expect(traces, hasLength(2));

        final dartTrace = traces.elementAt(1);
        expect(dartTrace.frames, hasLength(2));
        expect(dartTrace.frames.elementAt(0).method, equals('testThis'));
        expect(dartTrace.frames.elementAt(1).method, equals('what'));

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

        final trace = platformTraceInfo(exception, frames);
        final original = dataFrom(body: Body(report: trace));
        final transformed = await transformer.transform(
          Event(
              error: exception,
              stackTrace: StackTrace.empty,
              telemetry: telemetryMock),
          original,
        );

        final traces = transformed.body.report.traces;
        expect(traces, hasLength(3));

        final rootCause = traces.first;
        expect(rootCause.frames.length, greaterThan(1));
        expect(rootCause.frames.first.method, equals('thisWillBeRethrown'));

        final rethrownTrace = traces.elementAt(1);
        expect(rethrownTrace.frames, hasLength(2));
        expect(
            rethrownTrace.frames.elementAt(0).method, equals('processError'));
        expect(
            rethrownTrace.frames.elementAt(1).method, equals('catchAndThrow'));

        final dartTrace = traces.elementAt(2);
        expect(dartTrace.frames, hasLength(1));
        expect(dartTrace.frames.first.method, equals('onTheDartSide'));

        expect(dartTrace.exception.message, equals(expectedMessage));
      });
    });

    group('Platform transformer (appendToChain: false)', () {
      late PlatformTransformer transformer;

      setUp(() {
        transformer = PlatformTransformer(append: false);
      });

      test('Attach platform payload on PlatformException with chain', () async {
        final exception = androidPlatformException(
          topFrameMethod: 'toBeAttached',
          includeLineNumber: true,
        );

        const frames = [Frame(filename: filename, method: 'thisFails')];

        final platformTrace = platformTraceInfo(exception, frames);
        final original = dataFrom(body: Body(report: platformTrace));
        final transformed = await transformer.transform(
          Event(
              error: exception,
              stackTrace: StackTrace.empty,
              telemetry: telemetryMock),
          original,
        );

        final traces = transformed.body.report.traces;
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

        final trace = platformTraceInfo(exception, frames);
        final original = dataFrom(body: Body(report: trace));
        final transformed = await transformer.transform(
          Event(
              error: exception,
              stackTrace: StackTrace.empty,
              telemetry: telemetryMock),
          original,
        );

        final traces = transformed.body.report.traces;
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
