import 'dart:async';

import 'package:meta/meta.dart';

import 'config.dart';
import 'core_notifier.dart';
import 'uncaught_error.dart';
import 'rollbar_infrastructure.dart';
import 'api/payload/level.dart';

@sealed
class Rollbar {
  static late final Config config;
  static late final CoreNotifier notifier;
  static late final RollbarInfrastructure infrastructure;
  //final Future<UncaughtErrorHandler?> errorHandler;

  Rollbar._();

  static Future<void> run({required Config config}) async {
    Rollbar.config = config;
    Rollbar.infrastructure = await RollbarInfrastructure.start();
    Rollbar.notifier = CoreNotifier();

    // if (config.handleUncaughtErrors) {
    //   await UncaughtErrorHandler.start(
    //     config,
    //     rollbar._coreNotifier,
    //     infrastructure,
    //   );
    // }
  }

  /// Sends an error as an occurrence, with the provided level.
  static Future<void> log(
    Level level, {
    dynamic error,
    StackTrace? stackTrace,
    String? message,
  }) =>
      notifier.log(level, error, stackTrace, message, infrastructure);

  /// Sends an error as an occurrence, with DEBUG level.
  static Future<void> debug(dynamic error, StackTrace stackTrace) =>
      log(Level.debug, error: error, stackTrace: stackTrace);

  /// Sends an error as an occurrence, with INFO level.
  static Future<void> info(dynamic error, StackTrace stackTrace) =>
      log(Level.info, error: error, stackTrace: stackTrace);

  /// Sends an error as an occurrence, with WARNING level.
  static Future<void> warn(dynamic error, StackTrace stackTrace) =>
      log(Level.warning, error: error, stackTrace: stackTrace);

  /// Sends an error as an occurrence, with ERROR level.
  static Future<void> error(dynamic error, StackTrace stackTrace) =>
      log(Level.error, error: error, stackTrace: stackTrace);

  /// Sends an error as an occurrence, with CRITICAL level.
  static Future<void> critical(dynamic error, StackTrace stackTrace) =>
      log(Level.critical, error: error, stackTrace: stackTrace);
}
