// library rollbar_common;

// import 'dart:mirrors';

import 'package:logging/logging.dart';

extension SdkLogger on Logger {
  static const String _sdkLoggerName = 'com.rollbar.sdk';

  static String extendSdkModuleName({required String sdkModuleName}) {
    return '$_sdkLoggerName.$sdkModuleName';
  }

  // static late final String? _libName = reflect(ReflectionStub())
  //     .type
  //     .owner
  //     ?.simpleName
  //     .toString()
  //     .replaceFirst('Symbol("', '')
  //     .replaceFirst('")', '');
  // static late final Logger sdkLogger = Logger(_libName ?? 'com.rollbar.sdk');
  //OR just:
  static late final Logger sdkLogger = Logger(_sdkLoggerName);

  // @protected
  // static late final Logger commonModuleLogger =
  //     Logger(extendSdkModuleName(sdkModuleName: 'rollbar_common'));
}

// class ReflectionStub {}
