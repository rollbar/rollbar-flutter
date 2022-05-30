import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

@protected
class Module {
  static const String name = 'rollbar_flutter';
}

@protected
extension ModuleLogger on Logger {
  static final Logger moduleLogger =
      Logger(SdkLogger.extendSdkModuleName(sdkModuleName: Module.name));
}
