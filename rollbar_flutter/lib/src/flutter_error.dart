import 'package:flutter/foundation.dart';

import 'package:rollbar_common/rollbar_common.dart';
import 'package:rollbar_dart/rollbar.dart';

import 'extension/diagnostics.dart';

extension RollbarFlutterError on FlutterError {
  /// Called whenever the Flutter framework catches an error.
  ///
  /// The default behavior is to call [presentError].
  static void onError(FlutterErrorDetails error) {
    if (!error.silent) {
      Rollbar.drop(
        Breadcrumb.error(
          error.exceptionAsString(),
          extra: {
            'summary': error.summary.toDescription(),
            'context': error.context?.toDescription(),
            'info': error.information,
            'diagnostics': error.diagnostics,
            'library': error.library
          }.compact(),
        ),
      );

      Rollbar.error(error.exception, error.stack ?? StackTrace.empty);
    }

    FlutterError.presentError(error);
  }
}
