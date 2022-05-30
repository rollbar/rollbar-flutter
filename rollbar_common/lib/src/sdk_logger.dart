import 'package:logging/logging.dart';

extension SdkLogger on Logger {
  static const String _sdkLoggerName = 'com.rollbar.sdk';

  static String extendSdkModuleName({required String sdkModuleName}) {
    return '$_sdkLoggerName.$sdkModuleName';
  }

  static final Logger sdkLogger = Logger(_sdkLoggerName);
}
