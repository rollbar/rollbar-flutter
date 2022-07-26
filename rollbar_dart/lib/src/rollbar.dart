import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

import 'data/config.dart';
import 'data/payload/reading.dart';
import 'data/payload/data.dart';
import 'infrastructure.dart';
import 'core_notifier.dart';

@sealed
class Rollbar {
  static Rollbar? _current;
  static Rollbar get current => _current.orElse(() =>
      throw StateError('Rollbar has not been initialized, call Rollbar.run.'));

  final Infrastructure _infrastructure;
  final CoreNotifier _notifier;

  Rollbar._(this._infrastructure, this._notifier);

  static Future<void> run(Config config) async {
    if (_current != null) {
      await current._infrastructure.dispose();
    }

    _current = Rollbar._(
      await InfrastructureIsolate.spawn(config: config),
      CoreNotifier(config: config),
    );
  }

  @internal
  static void process({required Record record}) {
    current._infrastructure.process(record: record);
  }

  /// Logs a message as an occurrence.
  static Future<void> message(String message, {Level level = Level.info}) =>
      current._notifier.notify(level, null, null, message);

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

  /// Rollbar.add(Breadcrumb.navigation(from: ..., to: ...));
  //static Future<void> telemetry(Reading reading) {}
}
