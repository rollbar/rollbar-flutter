import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';
import 'package:rollbar_dart/src/notifier/notifier.dart';

import 'config.dart';
import 'occurrence.dart';
import 'data/payload/reading.dart';

@sealed
class Rollbar {
  static Rollbar? _current;
  static Rollbar get current => _current.orElse(() =>
      throw StateError('Rollbar has not been initialized, call Rollbar.run.'));

  final Notifier _notifier;

  Rollbar._(this._notifier);

  static Future<void> run(Config config) async {
    _current?._notifier.dispose();
    _current = Rollbar._(
      await config.notifier(config),
    );
  }

  /// Logs a message as an occurrence.
  ///
  /// Examples:
  /// ```dart
  /// Rollbar.log('Some message');
  /// ```
  static FutureOr<void> log(String message, {Level level = Level.info}) =>
      current._notifier.notify(Occurrence(
        level: level,
        message: message,
      ));

  /// Sends an error as an occurrence, with [Level.debug] level.
  static FutureOr<void> debug(dynamic error, StackTrace stackTrace) =>
      current._notifier.notify(Occurrence(
        level: Level.debug,
        error: error,
        stackTrace: stackTrace,
      ));

  /// Sends an error as an occurrence, with [Level.info] level.
  static FutureOr<void> info(dynamic error, StackTrace stackTrace) =>
      current._notifier.notify(Occurrence(
        level: Level.info,
        error: error,
        stackTrace: stackTrace,
      ));

  /// Sends an error as an occurrence, with [Level.warning] level.
  static FutureOr<void> warn(dynamic error, StackTrace stackTrace) =>
      current._notifier.notify(Occurrence(
        level: Level.warning,
        error: error,
        stackTrace: stackTrace,
      ));

  /// Sends an error as an occurrence, with [Level.error] level.
  static FutureOr<void> error(dynamic error, StackTrace stackTrace) =>
      current._notifier.notify(Occurrence(
        level: Level.error,
        error: error,
        stackTrace: stackTrace,
      ));

  /// Sends an error as an occurrence, with [Level.critical] level.
  static FutureOr<void> critical(dynamic error, StackTrace stackTrace) =>
      current._notifier.notify(Occurrence(
        level: Level.critical,
        error: error,
        stackTrace: stackTrace,
      ));

  static FutureOr<void> telemetry(Reading reading) {
    current._notifier.notify(Occurrence(
      reading: reading,
    ));
  }
}
