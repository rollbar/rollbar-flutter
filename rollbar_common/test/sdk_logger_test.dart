import 'package:test/test.dart';

import 'package:rollbar_common/src/sdk_logger.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('SDK Logger Name', () {
      expect(
          SdkLogger.sdkLogger.fullName == 'rollbar_common' ||
              SdkLogger.sdkLogger.fullName == 'com.rollbar.sdk' ||
              SdkLogger.sdkLogger.fullName == 'com.rollbar.sdk.rollbar_common',
          true);
      expect(
          SdkLogger.sdkLogger.name == 'rollbar_common' ||
              SdkLogger.sdkLogger.name == 'sdk' ||
              SdkLogger.sdkLogger.name == 'rollbar_common',
          true);
    });
  });
}
