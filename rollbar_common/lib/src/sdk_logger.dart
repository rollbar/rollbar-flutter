// library rollbar_common;

// import 'dart:mirrors';

import 'package:logging/logging.dart';

extension SdkLogger on Logger {
  // static late final String? _libName = reflect(ReflectionStub())
  //     .type
  //     .owner
  //     ?.simpleName
  //     .toString()
  //     .replaceFirst('Symbol("', '')
  //     .replaceFirst('")', '');
  // static late final Logger sdkLogger = Logger(_libName ?? 'com.rollbar.sdk');
  //OR just:
  static late final Logger sdkLogger = Logger('com.rollbar.sdk.rollbar_common');
}

// class ReflectionStub {}
