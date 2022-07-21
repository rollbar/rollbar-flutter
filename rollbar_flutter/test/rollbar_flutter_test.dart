import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rollbar_flutter/rollbar.dart';

import 'utils/platform_exception_utils.dart';

void main() {
  const channel = MethodChannel('com.rollbar.flutter');

  TestWidgetsFlutterBinding.ensureInitialized();
  late List<MethodCall> callsReceived;
  late MockSender sender;

  Config defaultConfig() => const Config(
      accessToken: 'SomeAccessToken',
      package: 'some_package_name',
      includePlatformLogs: true,
      handleUncaughtErrors: true,
      sender: mockSender);

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
    final config = defaultConfig();
    await RollbarFlutter.run(config, () {
      final initCalls =
          callsReceived.where((call) => call.method == 'initialize').toList();
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
      expect(init.arguments['persistPayloads'], equals(config.persistPayloads));
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

  test('Add platform_payload if PlatformException is enriched', () async {
    // Disable uncaught error handling, otherwise we initialize an error
    // handling isolate and we're forced to use a serializable sender factory,
    // instead of the closure
    final config = defaultConfig().copyWith(
      handleUncaughtErrors: false,
      sender: (_) => sender,
    );

    await RollbarFlutter.run(config, () async {
      final exception = androidPlatformException(
        topFrameMethod: 'platformSpecificStuff',
      );

      await Rollbar.error(exception, StackTrace.empty);

      final payload = verify(await sender.send(captureAny)).captured.single;
      expect(payload['data']['framework'], equals('flutter'));

      final platformPayload = payload['data']['platform_payload'];
      expect(platformPayload, isNotNull);
      expect(
          platformPayload['data']['notifier']['name'], equals('rollbar-java'));

      final frames = platformPayload['data']['body']['trace']['frames'];
      expect(frames.length, equals(2));
      expect(frames[0]['method'], equals('platformSpecificStuff'));
    });
  });
}

class MockSender extends Mock implements Sender {
  @override
  Future<bool> send(JsonMap? payload) {
    return super.noSuchMethod(
      Invocation.method(#send, [payload]),
      returnValue: Future<bool>.value(true),
    );
  }

  @override
  Future<bool> sendString(String _) async => true;
}

MockSender mockSender(Config _) => MockSender();
