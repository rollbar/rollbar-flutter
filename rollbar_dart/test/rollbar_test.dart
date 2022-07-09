import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:rollbar_dart/rollbar.dart';

Future<void> main() async {
  late MockSender sender;

  group('Rollbar notifier tests', () {
    setUp(() async {
      sender = MockSender();
      when(sender.send(any)).thenAnswer((_) async => true);

      //await rollbar.ensureInitialized();
    });

    tearDown(() {});

    test('When reporting single error it should send json payload', () async {
      final config = Config(
          accessToken: 'BlaBlaAccessToken',
          environment: 'production',
          codeVersion: '0.23.2',
          // handleUncaughtErrors must be set to false otherwise we can't use
          // a closure with a mock as the sender factory.
          handleUncaughtErrors: false,
          package: 'some_package_name',
          persistPayloads: true,
          sender: (_) => sender);

      final rollbar = await Rollbar.start(config: config);

      try {
        failingFunction();
      } catch (error, stackTrace) {
        await rollbar.error(error, stackTrace);
        var payload = verify(sender.send(captureAny)).captured.single;

        expect(payload['data']['code_version'], equals('0.23.2'));
        expect(payload['data']['level'], equals('error'));

        // Project root detection currently uses the `server` element of the payload,
        // so that's where we include it.
        var root = getPath(payload, ['data', 'server', 'root']);
        expect(root, equals('some_package_name'));

        var trace = getPath(payload, ['data', 'body', 'trace']);
        expect(trace['exception']['class'], equals('ArgumentError'));
        expect(trace['frames'].length, greaterThan(1));
        expect(trace['frames'][0]['method'], equals('failingFunction'));
      }
    });

    test('Optional fields should have defaults in the payload', () async {
      final config = Config(
          accessToken: 'BlaBlaAccessToken',
          package: 'some_package_name',
          sender: (_) => sender);

      final rollbar = await Rollbar.start(config: config);

      try {
        failingFunction();
      } catch (error, stackTrace) {
        await rollbar.error(error, stackTrace);
        var payload = verify(await sender.send(captureAny)).captured.single;

        Map data = payload['data'];
        expect(data, isNot(contains('code_version')));
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
          handleUncaughtErrors: false,
          transformer: ((_) => ExpandableTransformer()),
          sender: ((_) => sender));

      final rollbar = await Rollbar.start(config: config);

      await rollbar.error(
        ExpandableException(['a', 'b', 'c']),
        StackTrace.empty,
      );

      final payload = verify(await sender.send(captureAny)).captured.single;

      final body = getPath(payload, ['data', 'body']);
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
  @override
  Future<Data> transform(dynamic error, StackTrace? trace, Data data) async {
    // Simulates for example what we'd do with a PlatformException in Flutter
    if (error is ExpandableException) {
      List<TraceInfo?> traceChain = error.messages.map((message) {
        return TraceInfo()
          ..frames = []
          ..exception = (ExceptionInfo()
            ..clazz = 'testing'
            ..message = message);
      }).toList();

      traceChain.addAll(data.body.traces!);
      data.body = TraceChain()..traces = traceChain;
    }
    return data;
  }
}

class ExpandableException implements Exception {
  List<String> messages;
  ExpandableException(this.messages);

  @override
  String toString() {
    return 'ExpandableException with ${messages.length} messages';
  }
}

class MockSender extends Mock implements Sender {
  @override
  Future<bool> send(Map<String, dynamic>? payload) async {
    final returnValue = super.noSuchMethod(
      Invocation.method(#send, [payload]),
      returnValue: Future<bool>.value(true),
    );

    print(returnValue);

    expect(returnValue, const TypeMatcher<Future<bool>>());
    //expect(await returnValue, isTrue);

    return returnValue;
  }
}

dynamic getPath(Map<String, dynamic>? source, List<String> path) {
  // We're in a test, let the bounds checker handle the edge case of an empty path
  for (var i = 0;; ++i) {
    var key = path[i];

    expect(source, contains(key));
    var value = source![key];

    if (i == path.length - 1) {
      return value;
    } else {
      source = value as Map<String, dynamic>?;
    }
  }
}
