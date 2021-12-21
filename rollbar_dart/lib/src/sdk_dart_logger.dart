import 'dart:mirrors';

import 'package:logging/logging.dart';

extension SdkDartLogger on Logger {
  static late final String? _libName =
      reflect(SdkDartLogger.sdkDartLogger).type.owner?.simpleName.toString();
  static late final Logger sdkDartLogger =
      Logger(_libName ?? 'com.rollbar.dart');
}
