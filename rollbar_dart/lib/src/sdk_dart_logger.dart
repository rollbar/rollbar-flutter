import 'dart:mirrors';

import 'package:logging/logging.dart';

extension SdkDartLogger on Logger {
  static final String? _libName =
      reflect(SdkDartLogger.sdkDartLogger).type.owner?.simpleName.toString();
  static final Logger sdkDartLogger = Logger(_libName ?? 'com.rollbar.dart');
}
