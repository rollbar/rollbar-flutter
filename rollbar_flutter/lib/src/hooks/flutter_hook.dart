import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'package:rollbar_common/rollbar_common.dart';
import 'package:rollbar_dart/rollbar.dart';

import '../extension/diagnostics.dart';
import 'hook.dart';

@sealed
class FlutterHook implements Hook {
  FlutterExceptionHandler? _originalOnError;

  void onError(FlutterErrorDetails error) {
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

    if (_originalOnError != null) {
      _originalOnError!(error);
    }
  }

  @override
  void install(_) {
    _originalOnError = FlutterError.onError;
    FlutterError.onError = onError;
  }

  @override
  void uninstall() {
    if (FlutterError.onError == onError) {
      FlutterError.onError = _originalOnError;
      _originalOnError = null;
    }
  }
}
