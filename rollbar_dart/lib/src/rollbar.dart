import 'dart:async';
import 'dart:isolate';

import 'config.dart';
import 'core_notifier.dart';
import 'uncaught_error.dart';
import 'logging.dart' as logging;
import 'api/response.dart';
import 'api/payload/level.dart';

/// Rollbar notifier.
class Rollbar {
  Config _config;
  final CoreNotifier _coreNotifier;
  final Future<UncaughtErrorHandler> _errorHandler;

  Rollbar(this._config)
      : _coreNotifier = CoreNotifier(_config),
        _errorHandler =
            _resolveWithLogging(UncaughtErrorHandler.build(_config));

  /// Some initialization operations are asynchronous, such as initializing
  /// the [Isolate] that handles uncaught errors. This future can be awaited
  /// to ensure all async initialization operations are complete.
  Future<void> ensureInitialized() async {
    return _errorHandler;
  }

  /// Returns an error handler port which can be registered as an [Isolate]
  /// error listener, eg:
  ///
  /// ```dart
  /// Isolate.current.addErrorListener(await rollbar.errorHandler);
  /// ```
  Future<SendPort?>? get errorHandler async {
    return (await _errorHandler).errorHandlerPort;
  }

  /// Sends an error as an occurrence, with DEBUG level.
  Future<void> debug(dynamic error, StackTrace stackTrace) {
    return log(Level.debug, error, stackTrace);
  }

  /// Sends an error as an occurrence, with INFO level.
  Future<void> info(dynamic error, StackTrace stackTrace) {
    return log(Level.info, error, stackTrace);
  }

  /// Sends an error as an occurrence, with WARNING level.
  Future<void> warning(dynamic error, StackTrace stackTrace) {
    return log(Level.warning, error, stackTrace);
  }

  /// Sends an error as an occurrence, with ERROR level.
  Future<void> error(dynamic error, StackTrace stackTrace) {
    return log(Level.error, error, stackTrace);
  }

  /// Sends an error as an occurrence, with CRITICAL level.
  Future<void> critical(dynamic error, StackTrace stackTrace) {
    return log(Level.critical, error, stackTrace);
  }

  /// Sends an error as an occurrence, with the provided level.
  Future<void> log(Level level, dynamic error, StackTrace stackTrace) {
    return _processResponse(_coreNotifier.log(level, error, stackTrace, null));
  }

  /// Sends a message as an occurrence, with DEBUG level.
  Future<void> debugMsg(String message) {
    return logMsg(Level.debug, message);
  }

  /// Sends a message as an occurrence, with INFO level.
  Future<void> infoMsg(String message) {
    return logMsg(Level.info, message);
  }

  /// Sends a message as an occurrence, with WARNING level.
  Future<void> warningMsg(String message) {
    return logMsg(Level.warning, message);
  }

  /// Sends a message as an occurrence, with ERROR level.
  Future<void> errorMsg(String message) {
    return logMsg(Level.error, message);
  }

  /// Sends a message as an occurrence, with CRITICAL level.
  Future<void> criticalMsg(String message) {
    return logMsg(Level.critical, message);
  }

  /// Sends a message as an occurrence, with the provided level.
  Future<void> logMsg(Level level, String message) {
    return _processResponse(_coreNotifier.log(level, null, null, message));
  }

  /// The current notifier configuration.
  Config get config {
    return _config;
  }

  /// Updates the configuration of this instance.
  Future<void> configure(Config config) async {
    _config = config;
    await (await _errorHandler).configure(_config);
  }

  static Future<T> _resolveWithLogging<T>(Future<T> action) async {
    try {
      return await action;
    } on Exception catch (e) {
      logging.error('Internal error encountered while initializing Rollbar', e);
      rethrow;
    }
  }

  static Future<void> _processResponse(Future<Response> rollbarAction) async {
    try {
      var response = await rollbarAction;
      if (response.isError()) {
        logging.error('Error while sending data to Rollbar', response.message);
      }
    } on Exception catch (e) {
      logging.error(
          'Internal error encountered while sending data to Rollbar', e);
      rethrow;
    }
  }
}
