import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rollbar_flutter/rollbar_flutter.dart';
import 'package:rollbar_dart/src/wrangler/data_wrangler.dart';
import 'package:rollbar_flutter/src/platform_transformer.dart';

import 'utils/platform_exception_utils.dart';

void main() {
  group('DataWrangler tests', () {
    late MockSender sender;

    Config defaultConfig() => Config(
        accessToken: 'SomeAccessToken',
        package: 'some_package_name',
        framework: 'flutter',
        includePlatformLogs: true,
        handleUncaughtErrors: true,
        sender: (_) => sender,
        transformer: (_) => PlatformTransformer());

    setUp(() async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      sender = MockSender();
      when(sender.send(any)).thenAnswer((_) async => true);
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('Add platform_payload if PlatformException is enriched', () async {
      final exception = androidPlatformException(
        topFrameMethod: 'platformSpecificStuff',
      );

      final wrangler = DataWrangler(defaultConfig());
      final payload = await wrangler
          .payload(from: Event(error: exception))
          .then((payload) => payload.toMap());

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
  Future<bool> send(Map<String, dynamic>? payload) {
    return super.noSuchMethod(
      Invocation.method(#send, [payload]),
      returnValue: Future<bool>.value(true),
    );
  }
}
