import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'package:rollbar_dart/rollbar.dart';

import 'flutter_error.dart';
import 'platform_transformer.dart';

extension _Methods on MethodChannel {
  Future<void> initialize({required Config config}) async =>
      await invokeMethod('initialize', config.toMap());

  /// The platform-specific path where we can persist data if needed.
  Future<String> get persistencePath async =>
      await invokeMethod('persistencePath');
}

typedef RollbarClosure = FutureOr<void> Function();

@sealed
class RollbarFlutter {
  static const _platform = MethodChannel('com.rollbar.flutter');

  RollbarFlutter._();

  static Future<void> run(
    Config config,
    RollbarClosure appRunner,
  ) async {
    if (!config.handleUncaughtErrors) {
      WidgetsFlutterBinding.ensureInitialized();

      await _run(config, appRunner, null);

      return;
    }

    await runZonedGuarded(() async {
      WidgetsFlutterBinding.ensureInitialized();

      await _run(config, appRunner, RollbarFlutterError.onError);
    }, (exception, stackTrace) {
      Rollbar.error(exception, stackTrace);
    });
  }

  static Future<void> _run(
    Config config,
    RollbarClosure appRunner,
    FlutterExceptionHandler? onError,
  ) async {
    await Rollbar.run(config.copyWith(
      framework: 'flutter',
      persistencePath: await _platform.persistencePath,
      transformer: (_) => PlatformTransformer(),
    ));

    FlutterError.onError ??= onError;

    await _platform.initialize(config: config);
    await appRunner();
  }
}
