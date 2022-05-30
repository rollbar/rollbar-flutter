import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rollbar_common/src/sdk_logger.dart';

@protected
class Module {
  static const String name = 'rollbar_common';
}

@protected
extension ModuleLogger on Logger {
  static final Logger moduleLogger =
      Logger(SdkLogger.extendSdkModuleName(sdkModuleName: Module.name));
}
