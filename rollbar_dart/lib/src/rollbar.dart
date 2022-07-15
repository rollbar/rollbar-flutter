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

  @internal
  static late final RollbarInfrastructure infrastructure;

  @internal
  static late final CoreNotifier notifier;
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

  /// Logs a message as an occurrence.
  static Future<void> message(String message, {Level level = Level.info}) =>
      notifier.message(level, message);

  /// Sends an error as an occurrence, with [Level.debug] level.
  static Future<void> debug(dynamic error, StackTrace stackTrace) =>
      notifier.notify(Level.debug, error, stackTrace);

  /// Sends an error as an occurrence, with [Level.info] level.
  static Future<void> info(dynamic error, StackTrace stackTrace) =>
      notifier.notify(Level.info, error, stackTrace);

  /// Sends an error as an occurrence, with [Level.warning] level.
  static Future<void> warn(dynamic error, StackTrace stackTrace) =>
      notifier.notify(Level.warning, error, stackTrace);

  /// Sends an error as an occurrence, with [Level.error] level.
  static Future<void> error(dynamic error, StackTrace stackTrace) =>
      notifier.notify(Level.error, error, stackTrace);

  /// Sends an error as an occurrence, with [Level.critical] level.
  static Future<void> critical(dynamic error, StackTrace stackTrace) =>
      notifier.notify(Level.critical, error, stackTrace);
}
