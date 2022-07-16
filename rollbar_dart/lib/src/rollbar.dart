import 'dart:async';

import 'package:meta/meta.dart';

import 'config.dart';
import 'rollbar_infrastructure.dart';
import 'core_notifier.dart';
//import 'uncaught_error_handler.dart';
import 'payload_repository/payload_record.dart';
import 'api/payload/level.dart';

@sealed
class Rollbar {
  static Rollbar? _current;
  static Rollbar get current {
    if (_current == null) {
      throw StateError('Rollbar has not been initialized, call [Rollbar.run].');
    }
    return _current!;
  }

  final RollbarInfrastructure _infra;
  final CoreNotifier _notifier;
  //final Future<UncaughtErrorHandler?> errorHandler;

  Rollbar._(this._infra, this._notifier);

  static Future<void> run(Config config) async {
    if (_current != null) {
      await current._infra.dispose();
    }

    final infra = await RollbarInfrastructure.start(config: config);
    final notifier = CoreNotifier(config: config);
    _current = Rollbar._(infra, notifier);

    // if (config.handleUncaughtErrors) {
    //   await UncaughtErrorHandler.start(
    //     config,
    //     rollbar._coreNotifier,
    //     infrastructure,
    //   );
    // }
  }

  @internal
  static void process({required PayloadRecord record}) {
    current._infra.process(record: record);
  }

  /// Logs a message as an occurrence.
  static Future<void> message(String message, {Level level = Level.info}) =>
      current._notifier.message(level, message);

  /// Sends an error as an occurrence, with [Level.debug] level.
  static Future<void> debug(dynamic error, StackTrace stackTrace) =>
      current._notifier.notify(Level.debug, error, stackTrace);

  /// Sends an error as an occurrence, with [Level.info] level.
  static Future<void> info(dynamic error, StackTrace stackTrace) =>
      current._notifier.notify(Level.info, error, stackTrace);

  /// Sends an error as an occurrence, with [Level.warning] level.
  static Future<void> warn(dynamic error, StackTrace stackTrace) =>
      current._notifier.notify(Level.warning, error, stackTrace);

  /// Sends an error as an occurrence, with [Level.error] level.
  static Future<void> error(dynamic error, StackTrace stackTrace) =>
      current._notifier.notify(Level.error, error, stackTrace);

  /// Sends an error as an occurrence, with [Level.critical] level.
  static Future<void> critical(dynamic error, StackTrace stackTrace) =>
      current._notifier.notify(Level.critical, error, stackTrace);
}
