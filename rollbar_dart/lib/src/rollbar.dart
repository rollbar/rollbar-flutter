import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';
import 'package:rollbar_dart/src/notifier/notifier.dart';

import 'config.dart';
import 'data/event.dart';
import 'data/payload/reading.dart';
import 'telemetry.dart';

@sealed
class Rollbar {
  static Rollbar? _current;
  static Rollbar get current => _current.orElse(() =>
      throw StateError('Rollbar has not been initialized, call Rollbar.run.'));

  final Notifier _notifier;
  final Telemetry _telemetry;

  Rollbar._(this._notifier, this._telemetry);

  static Future<void> run(Config config) async {
    _current?._notifier.dispose();
    _current = Rollbar._(
      await config.notifier(config),
      Telemetry(config),
    );
  }

  /// Logs a message as an occurrence.
  ///
  /// Examples:
  /// ```dart
  /// Rollbar.log('Some message');
  /// ```
  static FutureOr<void> log(String message, {Level level = Level.info}) async =>
      Rollbar.current._notifier.notify(Event(
        level: level,
        message: message,
        telemetry: Rollbar.current._telemetry.snapshot(),
      ));

  /// Sends an error as an occurrence, with [Level.debug] level.
  static FutureOr<void> debug(dynamic error, StackTrace stackTrace) =>
      Rollbar.current._notifier.notify(Event(
        level: Level.debug,
        error: error,
        stackTrace: stackTrace,
        telemetry: Rollbar.current._telemetry.snapshot(),
      ));

  /// Sends an error as an occurrence, with [Level.info] level.
  static FutureOr<void> info(dynamic error, StackTrace stackTrace) =>
      Rollbar.current._notifier.notify(Event(
        level: Level.info,
        error: error,
        stackTrace: stackTrace,
        telemetry: Rollbar.current._telemetry.snapshot(),
      ));

  /// Sends an error as an occurrence, with [Level.warning] level.
  static FutureOr<void> warn(dynamic error, StackTrace stackTrace) =>
      Rollbar.current._notifier.notify(Event(
        level: Level.warning,
        error: error,
        stackTrace: stackTrace,
        telemetry: Rollbar.current._telemetry.snapshot(),
      ));

  /// Sends an error as an occurrence, with [Level.error] level.
  static FutureOr<void> error(dynamic error, StackTrace stackTrace) =>
      Rollbar.current._notifier.notify(Event(
        level: Level.error,
        error: error,
        stackTrace: stackTrace,
        telemetry: Rollbar.current._telemetry.snapshot(),
      ));

  /// Sends an error as an occurrence, with [Level.critical] level.
  static FutureOr<void> critical(dynamic error, StackTrace stackTrace) =>
      Rollbar.current._notifier.notify(Event(
        level: Level.critical,
        error: error,
        stackTrace: stackTrace,
        telemetry: Rollbar.current._telemetry.snapshot(),
      ));

  static FutureOr<void> telemetry(Reading reading) {
    Rollbar.current._telemetry.register(reading);
  }
}
