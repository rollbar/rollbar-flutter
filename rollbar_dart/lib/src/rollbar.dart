import 'dart:async';
import 'dart:isolate';

import 'package:meta/meta.dart';

import 'config.dart';
import 'core_notifier.dart';
import 'uncaught_error.dart';
import 'rollbar_infrastructure.dart';
import 'api/payload/level.dart';

@sealed
class Rollbar {
  final Config config;
  final CoreNotifier _coreNotifier;
  final RollbarInfrastructure _infrastructure;
  //final Future<UncaughtErrorHandler?> errorHandler;

  Rollbar._(this.config, this._infrastructure, this._coreNotifier);

  static Future<Rollbar> start({required Config config}) async {
    final infrastructure = await RollbarInfrastructure.start(config: config);
    final notifier = CoreNotifier(config);
    final rollbar = Rollbar._(config, infrastructure, notifier);

    // if (config.handleUncaughtErrors) {
    //   await UncaughtErrorHandler.start(
    //     config,
    //     rollbar._coreNotifier,
    //     infrastructure,
    //   );
    // }

    return rollbar;
  }

  //errorHandler = UncaughtErrorHandler.build(_config);

  /// Some initialization operations are asynchronous, such as initializing
  /// the [Isolate] that handles uncaught errors. This future can be awaited
  /// to ensure all async initialization operations are complete.
//  Future<UncaughtErrorHandler> ensureInitialized() async => _errorHandler;

  /// Returns an error handler port which can be registered as an [Isolate]
  /// error listener, eg:
  ///
  /// ```dart
  /// Isolate.current.addErrorListener(await rollbar.errorHandler);
  /// ```
//  Future<SendPort?>? get errorHandler async => (await _errorHandler).errorPort;

  /// Sends an error as an occurrence, with the provided level.
  Future<void> log(Level level, dynamic error, StackTrace stackTrace) =>
      _coreNotifier.log(level, error, stackTrace, null, _infrastructure);

  /// Sends a message as an occurrence, with the provided level.
  Future<void> logMsg(Level level, String message) =>
      _coreNotifier.log(level, null, null, message, _infrastructure);

  /// Sends an error as an occurrence, with DEBUG level.
  Future<void> debug(dynamic error, StackTrace stackTrace) =>
      log(Level.debug, error, stackTrace);

  /// Sends an error as an occurrence, with INFO level.
  Future<void> info(dynamic error, StackTrace stackTrace) =>
      log(Level.info, error, stackTrace);

  /// Sends an error as an occurrence, with WARNING level.
  Future<void> warning(dynamic error, StackTrace stackTrace) =>
      log(Level.warning, error, stackTrace);

  /// Sends an error as an occurrence, with ERROR level.
  Future<void> error(dynamic error, StackTrace stackTrace) =>
      log(Level.error, error, stackTrace);

  /// Sends an error as an occurrence, with CRITICAL level.
  Future<void> critical(dynamic error, StackTrace stackTrace) =>
      log(Level.critical, error, stackTrace);

  /// Sends a message as an occurrence, with DEBUG level.
  Future<void> debugMsg(String message) => logMsg(Level.debug, message);

  /// Sends a message as an occurrence, with INFO level.
  Future<void> infoMsg(String message) => logMsg(Level.info, message);

  /// Sends a message as an occurrence, with WARNING level.
  Future<void> warningMsg(String message) => logMsg(Level.warning, message);

  /// Sends a message as an occurrence, with ERROR level.
  Future<void> errorMsg(String message) => logMsg(Level.error, message);

  /// Sends a message as an occurrence, with CRITICAL level.
  Future<void> criticalMsg(String message) => logMsg(Level.critical, message);
}
