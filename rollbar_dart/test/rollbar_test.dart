import 'package:mockito/mockito.dart';
import 'package:rollbar_dart/rollbar.dart';
import 'package:rollbar_dart/src/api/payload/body.dart';
import 'package:rollbar_dart/src/api/payload/data.dart';
import 'package:rollbar_dart/src/api/payload/exception_info.dart';
import 'package:rollbar_dart/src/api/response.dart';
import 'package:rollbar_dart/src/transformer.dart';
import 'package:test/test.dart';

void main() {
  group('Rollbar notifier tests', () {
    Rollbar rollbar;
    Sender sender;

    setUp(() async {
      sender = MockSender();
      when(sender.send(any))
          .thenAnswer((_invocation) => Future.value(Response()));
      // handleUncaughtErrors must be set to false otherwise we can't use a closure with a
      // mock as the sender factory.
      var config = (ConfigBuilder('BlaBlaAccessToken')
            ..environment = 'production'
            ..codeVersion = '1.0.0'
            ..handleUncaughtErrors = false
            ..sender = (_) => sender)
          .build();

      rollbar = Rollbar(config);
      await rollbar.ensureInitialized();
    });

    test('When reporting single error it should send json payload', () async {
      try {
        failingFunction();
      } catch (error, stackTrace) {
        await rollbar.error(error, stackTrace);
        var payload = verify(await sender.send(captureAny)).captured.single;

        expect(payload['data']['level'], equals('error'));

        var trace = getPath(payload, ['data', 'body', 'trace']);

        expect(trace['exception']['class'], equals('ArgumentError'));
        expect(trace['frames'].length, greaterThan(1));
        expect(trace['frames'][0]['method'], equals('failingFunction'));
      }
    });

    test('If error trasformer is provided it should transform error', () async {
      var config = (ConfigBuilder('token')
            ..environment = 'production'
            ..codeVersion = '1.0.0'
            ..handleUncaughtErrors = false
            ..transformer = ((_) => ExpandableTransformer())
            ..sender = ((_) => sender))
          .build();

      rollbar = Rollbar(config);

      await rollbar.error(
          ExpandableException(['a', 'b', 'c']), StackTrace.empty);

      var payload = verify(await sender.send(captureAny)).captured.single;

      var body = getPath(payload, ['data', 'body']);
      expect(body, contains('trace_chain'));

      var chain = body['trace_chain'];
      expect(chain, hasLength(4));
    });
  });
}

void failingFunction() {
  throw ArgumentError('Test error');
}

class ExpandableTransformer implements Transformer {
  @override
  Future<Data> transform(dynamic error, StackTrace trace, Data data) async {
    // Simulates for example what we'd do with a PlatformException in Flutter
    if (error is ExpandableException) {
      var traceChain = error.messages.map((message) {
        return TraceInfo()
          ..frames = []
          ..exception = (ExceptionInfo()
            ..clazz = 'testing'
            ..message = message);
      }).toList();

      traceChain.addAll(data.body.getTraces());
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

class MockSender extends Mock implements Sender {}

dynamic getPath(Map<String, dynamic> source, List<String> path) {
  // We're in a test, let the bounds checker handle the edge case of an empty path
  for (var i = 0;; ++i) {
    var key = path[i];

    expect(source, contains(key));
    var value = source[key];

    if (i == path.length - 1) {
      return value;
    } else {
      source = value as Map<String, dynamic>;
    }
  }
}
