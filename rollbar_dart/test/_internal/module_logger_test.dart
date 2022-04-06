import 'package:test/test.dart';

import 'package:rollbar_common/src/sdk_logger.dart';
import 'package:rollbar_dart/src/_internal/module.dart';

const String expectedModuleLoggerName = 'rollbar_dart';
const String expectedModuleLoggerFullName =
    'com.rollbar.sdk.$expectedModuleLoggerName';

void main() {
  group('Named logger tests:', () {
    test('SDK Logger Name', () {
      expect(SdkLogger.sdkLogger.fullName == 'com.rollbar.sdk', true);
      expect(SdkLogger.sdkLogger.name == 'sdk', true);
    });

    test('Module Logger Name', () {
      expect(
          ModuleLogger.moduleLogger.fullName ==
              'com.rollbar.sdk.${Module.name}',
          true);
      expect(ModuleLogger.moduleLogger.fullName == expectedModuleLoggerFullName,
          true);
      expect(ModuleLogger.moduleLogger.name == Module.name, true);
      expect(ModuleLogger.moduleLogger.name == expectedModuleLoggerName, true);
    });
  });
}
