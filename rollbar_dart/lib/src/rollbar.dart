import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';
import 'package:rollbar_dart/rollbar.dart';
import 'package:rollbar_dart/src/data/event.dart';

@sealed
class Rollbar {
  static Rollbar? _current;
  static Rollbar get current => _current.orElse(() =>
      throw StateError('Rollbar has not been initialized, call Rollbar.run.'));

  final Sandbox _sandbox;

  Rollbar._(this._sandbox);

  static Future<void> run(Config config) async {
    _current?._sandbox.dispose();
    _current = Rollbar._(
      await config.sandbox(config),
    );
  }

  static FutureOr<void> log(
    dynamic errorOrMessage, {
    StackTrace stackTrace = StackTrace.empty,
    Level level = Level.info,
  }) async {
    final Event event;
    if (errorOrMessage is Error || errorOrMessage is Exception) {
      event = ErrorEvent(errorOrMessage, stackTrace, level: level);
    } else if (errorOrMessage is Object) {
      event = MessageEvent(errorOrMessage.toString(), level: level);
    } else {
      throw ArgumentError.value(
        errorOrMessage,
        'errorOrMessage',
        'Rollbar can only log Error, Exception or Dart Object types.',
      );
    }

    await current._sandbox.dispatch(event);
  }

  /// Sends an error as an occurrence, with [Level.debug] level.
  static FutureOr<void> debug(
    dynamic errorOrMessage, [
    StackTrace stackTrace = StackTrace.empty,
  ]) async =>
      await log(errorOrMessage, stackTrace: stackTrace, level: Level.debug);

  /// Sends an error as an occurrence, with [Level.info] level.
  static FutureOr<void> info(
    dynamic errorOrMessage, [
    StackTrace stackTrace = StackTrace.empty,
  ]) async =>
      await log(errorOrMessage, stackTrace: stackTrace, level: Level.info);

  /// Sends an error as an occurrence, with [Level.warning] level.
  static FutureOr<void> warn(
    dynamic errorOrMessage, [
    StackTrace stackTrace = StackTrace.empty,
  ]) async =>
      await log(errorOrMessage, stackTrace: stackTrace, level: Level.warning);

  /// Sends an error as an occurrence, with [Level.error] level.
  static FutureOr<void> error(
    dynamic errorOrMessage, [
    StackTrace stackTrace = StackTrace.empty,
  ]) async =>
      await log(errorOrMessage, stackTrace: stackTrace, level: Level.error);

  /// Sends an error as an occurrence, with [Level.critical] level.
  static FutureOr<void> critical(
    dynamic errorOrMessage, [
    StackTrace stackTrace = StackTrace.empty,
  ]) async =>
      await log(errorOrMessage, stackTrace: stackTrace, level: Level.critical);

  /// Sets or unsets a user.
  static FutureOr<void> setUser(User? user) async {
    await current._sandbox.dispatch(UserEvent(user));
  }

  /// Drops a breadcrumb with information about state, a change of state, an
  /// event such as the user interacting with a widget, or navigating from one
  /// place to another or any custom data.
  ///
  /// Breadcrumbs are events gathered by Rollbar's Telemetry which can help you
  /// understand the events leading up to an occurrence such as an error,
  /// exception or crash.
  ///
  /// - See also: [Breadcrumb].
  static FutureOr<void> drop(Breadcrumb breadcrumb) async {
    await current._sandbox.dispatch(TelemetryEvent(breadcrumb));
  }
}
