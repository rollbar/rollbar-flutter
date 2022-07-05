import 'package:test/test.dart';

import 'package:rollbar_dart/rollbar.dart';

void main() {
  group('Live Rollbar tests:', () {
    setUp(() {
      // Additional setup goes here.
    });

    tearDown(() {});

    test('basic test', () async {
      var config = (ConfigBuilder('17965fa5041749b6bf7095a190001ded')
            ..environment = 'development'
            ..codeVersion = '0.1.0'
            ..package = 'rollbar_dart_example'
            ..persistPayloads = true
            ..handleUncaughtErrors = true)
          .build();

      await RollbarInfrastructure.instance.initialize(config: config);

      final rollbar = Rollbar(config);
      await rollbar.ensureInitialized();
      await rollbar.criticalMsg('Rollbar-Flutter live test!');

      // expect(SdkLogger.sdkLogger.fullName == 'com.rollbar.sdk', true);
      // expect(SdkLogger.sdkLogger.name == 'sdk', true);

      await Future.delayed(Duration(seconds: 5));
      await RollbarInfrastructure.instance.dispose();
    });
  });
}
