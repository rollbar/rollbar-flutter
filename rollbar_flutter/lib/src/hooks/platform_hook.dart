import 'dart:ui';
import 'package:rollbar_dart/rollbar.dart';
import 'hook.dart';

class PlatformHook implements Hook {
  ErrorCallback? _originalOnError;
  PlatformDispatcher? _platformDispatcher;

  static bool get isAvailable {
    try {
      (PlatformDispatcher.instance as dynamic)?.onError;
      return true;
    } on NoSuchMethodError {
      return false;
    }
  }

  bool onError(Object exception, StackTrace stackTrace) {
    Rollbar.error(exception, stackTrace);

    if (_originalOnError != null) {
      return _originalOnError!(exception, stackTrace);
    }

    return false;
  }

  @override
  void install(_) {
    _platformDispatcher = PlatformDispatcher.instance;
    _originalOnError = _platformDispatcher?.onError;
    _platformDispatcher?.onError = onError;
  }

  @override
  void uninstall() {
    if (_platformDispatcher?.onError == onError) {
      _platformDispatcher?.onError = _originalOnError;
      _originalOnError = null;
      _platformDispatcher = null;
    }
  }
}
