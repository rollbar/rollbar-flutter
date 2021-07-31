import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'flutter1_workarounds.dart' as rbdart;
import 'package:rollbar_flutter/rollbar.dart';

import 'platform_exception_utils.dart';

void main() {
  const channel = MethodChannel('rollbar_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();
  List<MethodCall> callsReceived;
  MockSender sender;

  setUp(() async {
    rbdart.RollbarPlatformInfo.isAndroid = true;
    sender = MockSender();
    when(sender.send(any))
        .thenAnswer((_invocation) => Future.value(rbdart.Response()));

    callsReceived = [];
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      callsReceived.add(methodCall);
      return '42';
    });
  });

  tearDown(() {
    rbdart.RollbarPlatformInfo.reset();
    channel.setMockMethodCallHandler(null);
  });

  ConfigBuilder defaultConfig() {
    return ConfigBuilder('BlaBlaAccessToken')
      ..environment = 'production'
      ..codeVersion = '0.1.0beta'
      ..includePlatformLogs = true
      ..handleUncaughtErrors = true
      ..sender = createMockSender;
  }

  List<MethodCall> getCalls(String method) {
    return callsReceived.where((c) => c.method == method).toList();
  }

  test('When running application it should initialize platform component',
      () async {
    var config = defaultConfig().build();

    await _runRollbarFlutter(config, (rollbar) async {
      var initCalls = getCalls('initialize');
      expect(initCalls.length, equals(1));
      var init = initCalls[0];
      // These are the arguments the our platform plugin expects:
      expect(init.arguments.length, equals(8));
      expect(
          init.arguments['instanceId'], equals(rollbar.instanceId.toString()));
      expect(init.arguments['isGlobalInstance'], equals(true));
      expect(init.arguments['endpoint'], equals(config.endpoint));
      expect(init.arguments['accessToken'], equals(config.accessToken));
      expect(init.arguments['environment'], equals(config.environment));
      expect(init.arguments['codeVersion'], equals(config.codeVersion));
      expect(init.arguments['handleUncaughtErrors'],
          equals(config.handleUncaughtErrors));
      expect(init.arguments['includePlatformLogs'],
          equals(config.includePlatformLogs));
    });
  });

  test('if error is default PlatformException it should parse java trace',
      () async {
    //fail('TODO');
  });

  test('if error is enriched PlatformException it should add platform_payload',
      () async {
    // Disable uncaught error handling, otherwise we initialize an error handling
    // isolate and we're forced to use a serializable sender factory, instead
    // of the closure
    var config = (defaultConfig()
          ..handleUncaughtErrors = false
          ..sender = ((config) => sender))
        .build();

    await _runRollbarFlutter(config, (rollbar) async {
      var exception = createAndroidPlatformException(
          topFrameMethod: 'getPlatformSpecificStuff');

      await rollbar.error(exception, StackTrace.empty);

      var payload = verify(await sender.send(captureAny)).captured.single;

      expect(payload['data']['framework'], equals('flutter'));

      var platformPayload = payload['data']['platform_payload'];
      expect(platformPayload, isNotNull);
      expect(
          platformPayload['data']['notifier']['name'], equals('rollbar-java'));

      var frames = platformPayload['data']['body']['trace']['frames'];
      expect(frames.length, equals(2));
      expect(frames[0]['method'], equals('getPlatformSpecificStuff'));
    });
  });
}

Future<void> _runRollbarFlutter(
    Config config, FutureOr<void> Function(RollbarFlutter) action) async {
  var run = false;
  await RollbarFlutter.run(config, (rollbar) async {
    await action(rollbar);
    run = true;
  });
  expect(run, equals(true));
}

class MockSender extends Mock implements rbdart.Sender {}

MockSender createMockSender(Config c) {
  return MockSender();
}
