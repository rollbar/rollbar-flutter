import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rollbar_dart/rollbar_dart.dart';
import 'flutter1_workarounds.dart' as rbdart;
import 'package:rollbar_flutter/rollbar.dart';

import 'platform_exception_utils.dart';

void main() {
  const channel = MethodChannel('rollbar_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();
  late List<MethodCall> callsReceived;
  late MockSender sender;

  setUp(() async {
    rbdart.RollbarPlatformInfo.isAndroid = true;
    sender = MockSender();
    when(sender.send(any)).thenAnswer((_) async => true);

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

  Config defaultConfig() {
    return Config(
        accessToken: 'BlaBlaAccessToken',
        environment: 'production',
        package: 'some_package_name',
        codeVersion: '0.1.0beta',
        includePlatformLogs: true,
        handleUncaughtErrors: true,
        sender: createMockSender);
  }

  List<MethodCall> getCalls(String method) {
    return callsReceived.where((c) => c.method == method).toList();
  }

  test('When running application it should initialize platform component',
      () async {
    final config = defaultConfig();
    final _ = await RollbarFlutter.start(config: config);

    var initCalls = getCalls('initialize');
    expect(initCalls.length, equals(1));
    var init = initCalls[0];
    // These are the arguments the our platform plugin expects:
    expect(init.arguments.length, equals(8));
    expect(init.arguments['endpoint'], equals(config.endpoint));
    expect(init.arguments['accessToken'], equals(config.accessToken));
    expect(init.arguments['environment'], equals(config.environment));
    expect(init.arguments['codeVersion'], equals(config.codeVersion));
    expect(init.arguments['handleUncaughtErrors'],
        equals(config.handleUncaughtErrors));
    expect(init.arguments['includePlatformLogs'],
        equals(config.includePlatformLogs));
  });

  test('if error is default PlatformException it should parse java trace',
      () async {
    //fail('TODO');
  });

  test('if error is enriched PlatformException it should add platform_payload',
      () async {
    // await RollbarInfrastructure.instance
    //     .initialize(withPersistentPayloadStore: true);

    // Disable uncaught error handling, otherwise we initialize an error handling
    // isolate and we're forced to use a serializable sender factory, instead
    // of the closure
    var config = Config.from(defaultConfig(),
        handleUncaughtErrors: false, sender: (config) => sender);

    final rollbar = await RollbarFlutter.start(config: config);

    var exception = createAndroidPlatformException(
        topFrameMethod: 'getPlatformSpecificStuff');

    await rollbar.error(exception, StackTrace.empty);

    var payload = verify(await sender.send(captureAny)).captured.single;

    expect(payload['data']['framework'], equals('flutter'));

    var platformPayload = payload['data']['platform_payload'];
    expect(platformPayload, isNotNull);
    expect(platformPayload['data']['notifier']['name'], equals('rollbar-java'));

    var frames = platformPayload['data']['body']['trace']['frames'];
    expect(frames.length, equals(2));
    expect(frames[0]['method'], equals('getPlatformSpecificStuff'));
  });
}

class MockSender extends Mock implements rbdart.Sender {
  @override
  Future<bool> send(Map<String, dynamic>? payload) {
    return super.noSuchMethod(Invocation.method(#send, [payload]),
        returnValue: Future<bool>.value(true));
  }
}

MockSender createMockSender(Config c) {
  return MockSender();
}
