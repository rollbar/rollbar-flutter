import 'package:rollbar_dart/src/notifier/async_notifier.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:rollbar_dart/rollbar.dart';

Future<void> main() async {
  late MockSender sender;

  /// https://stackoverflow.com/questions/73145803/dart-unit-testing-code-that-runs-in-an-isolate
  group('Rollbar notifier tests', () {
    setUp(() async {
      sender = MockSender();
      when(sender.send(any)).thenAnswer((_) async => true);
    });

    tearDown(() {});

    test('When reporting single error it should send json payload', () async {
      final config = Config(
          accessToken: 'BlaBlaAccessToken',
          environment: 'production',
          codeVersion: '0.23.2',
          package: 'some_package_name',
          handleUncaughtErrors: true,
          notifier: AsyncNotifier.new,
          sender: (_) => sender);

      await Rollbar.run(config);

      try {
        failingFunction();
      } catch (error, stackTrace) {
        await Rollbar.error(error, stackTrace);
        final payload = verify(sender.send(captureAny)).captured.single;

        expect(payload['data']['code_version'], equals('0.23.2'));
        expect(payload['data']['level'], equals('error'));

        final root = payload['data']['server']['root'];
        expect(root, equals('some_package_name'));

        final trace = payload['data']['body']['trace'];
        expect(trace['exception']['class'], equals('ArgumentError'));
        expect(trace['frames'].length, greaterThan(1));
        expect(trace['frames'][0]['method'], equals('failingFunction'));
      }
    });

    test('Optional fields should have defaults in the payload', () async {
      final config = Config(
          accessToken: 'BlaBlaAccessToken',
          package: 'some_package_name',
          notifier: AsyncNotifier.new,
          sender: (_) => sender);

      await Rollbar.run(config);

      try {
        failingFunction();
      } catch (error, stackTrace) {
        await Rollbar.error(error, stackTrace);
        final payload = verify(sender.send(captureAny)).captured.single;

        Map data = payload['data'];
        expect(data['code_version'], equals('main'));
        expect(data['framework'], equals('dart'));
        expect(data['environment'], equals('development'));
        expect(data, isNot(contains('platform_payload')));
      }
    });

    test('If error trasformer is provided it should transform error', () async {
      final config = Config(
          accessToken: 'token',
          environment: 'production',
          codeVersion: '1.0.0',
          package: 'some_package_name',
          handleUncaughtErrors: true,
          notifier: AsyncNotifier.new,
          transformer: ExpandableTransformer.new,
          sender: ((_) => sender));

      await Rollbar.run(config);

      await Rollbar.error(
        ExpandableException(['a', 'b', 'c']),
        StackTrace.empty,
      );

      final payload = verify(await sender.send(captureAny)).captured.single;

      final body = payload['data']['body'];
      expect(body, contains('trace_chain'));

      final chain = body['trace_chain'];
      expect(chain, hasLength(4));
    });
  });
}

void failingFunction() {
  throw ArgumentError('Test error');
}

class ExpandableTransformer implements Transformer {
  const ExpandableTransformer(Config _);

  @override
  Future<Data> transform(Event event, Data data) async {
    expect(event.error, TypeMatcher<ExpandableException>());

    final traceChain = (event.error.messages as List<String>)
        .map((message) => TraceInfo(
            frames: [],
            exception: ExceptionInfo(type: 'testing', message: message)))
        .toList()
      ..addAll(data.body.traces);

    return data.copyWith(body: TraceChain(traceChain));
  }
}

class ExpandableException implements Exception {
  List<String> messages;

  ExpandableException(this.messages);

  @override
  String toString() => 'ExpandableException with ${messages.length} messages';
}

class MockSender extends Mock implements Sender {
  @override
  Future<bool> send(Map<String, dynamic>? payload) async {
    return super.noSuchMethod(
      Invocation.method(#send, [payload]),
      returnValue: Future<bool>.value(true),
    );
  }
}
