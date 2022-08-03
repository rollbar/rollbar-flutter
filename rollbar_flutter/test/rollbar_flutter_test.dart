import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rollbar_dart/src/notifier/async_notifier.dart';
import 'package:rollbar_flutter/rollbar.dart';

import 'utils/platform_exception_utils.dart';

void main() {
  const channel = MethodChannel('com.rollbar.flutter');

  TestWidgetsFlutterBinding.ensureInitialized();
  late List<MethodCall> callsReceived;
  late MockSender sender;

  setUp(() async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    sender = MockSender();
    when(sender.send(any)).thenAnswer((_) async => true);

    callsReceived = [];
    channel.setMockMethodCallHandler((methodCall) async {
      callsReceived.add(methodCall);
      return '42';
    });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    channel.setMockMethodCallHandler(null);
  });

  test('Initialize platform component when running application', () async {
    final config = Config(
        accessToken: 'SomeAccessToken',
        package: 'some_package_name',
        includePlatformLogs: true,
        handleUncaughtErrors: true,
        notifier: AsyncNotifier.new,
        sender: (_) => sender);

    await RollbarFlutter.run(config, () {
      final initCalls = callsReceived //
          .where((call) => call.method == 'initialize')
          .toList();
      expect(initCalls.length, equals(1));

      final init = initCalls[0];
      // These are the arguments the our platform plugin expects:
      expect(init.arguments.length, equals(9));
      expect(init.arguments['accessToken'], equals(config.accessToken));
      expect(init.arguments['endpoint'], equals(config.endpoint));
      expect(init.arguments['environment'], equals(config.environment));
      expect(init.arguments['framework'], equals(config.framework));
      expect(init.arguments['codeVersion'], equals(config.codeVersion));
      expect(init.arguments['package'], equals(config.package));
      expect(init.arguments['persistenceLifetime'],
          equals(config.persistenceLifetime));
      expect(init.arguments['handleUncaughtErrors'],
          equals(config.handleUncaughtErrors));
      expect(init.arguments['includePlatformLogs'],
          equals(config.includePlatformLogs));
    });
  });

  test('Add platform_payload if PlatformException is enriched', () async {
    final config = Config(
        accessToken: 'SomeAccessToken',
        package: 'some_package_name',
        includePlatformLogs: true,
        handleUncaughtErrors: true,
        notifier: AsyncNotifier.new,
        sender: (_) => sender);

    await RollbarFlutter.run(config, () async {
      final platformException = androidPlatformException(
        topFrameMethod: 'platformSpecificStuff',
      );

      await Rollbar.error(platformException, StackTrace.empty);

      final payload = verify(await sender.send(captureAny)).captured.single;
      expect(payload['data']['framework'], equals('flutter'));

      final platformPayload = payload['data']['platform_payload'];
      expect(platformPayload, isNotNull);
      expect(
          platformPayload['data']['notifier']['name'], equals('rollbar-java'));
      expect(platformPayload['data']['notifier']['version'], equals('0.0.1'));

      final exception = platformPayload['data']['body']['trace']['exception'];
      expect(exception['description'], equals('Invalid counter state: 1'));
      expect(exception['message'], equals('Invalid counter state: 1'));
      expect(exception['class'], equals('java.lang.IllegalStateException'));

      final frames = platformPayload['data']['body']['trace']['frames'];
      expect(frames.length, equals(2));
      expect(frames[0]['filename'], equals('MainActivity.java'));
      expect(frames[0]['method'], equals('platformSpecificStuff'));
      expect(frames[0]['lineno'], equals(47));
      expect(frames[0]['class_name'],
          equals('com.rollbar.flutter.example.MainActivity'));
      expect(frames[1]['filename'], equals('MainActivity.java'));
      expect(frames[1]['method'], equals('onMethodCall'));
      expect(frames[1]['lineno'], equals(37));
      expect(frames[1]['class_name'],
          equals('com.rollbar.flutter.example.MainActivity'));
    });
  });
}

class MockSender extends Mock implements Sender {
  @override
  Future<bool> send(Map<String, dynamic>? payload) {
    return super.noSuchMethod(
      Invocation.method(#send, [payload]),
      returnValue: Future<bool>.value(true),
    );
  }
}
