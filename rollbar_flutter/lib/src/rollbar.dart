import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:rollbar_dart/rollbar.dart';

import 'platform_transformer.dart';

extension _Methods on MethodChannel {
  Future<void> initialize({required Config config}) async =>
      await invokeMethod('initialize', config.toMap());

  /// The platform-specific path where we can persist our database if needed.
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
    WidgetsFlutterBinding.ensureInitialized();

    await Rollbar.run(config.copyWith(
      framework: 'flutter',
      persistencePath: await _platform.persistencePath,
      transformer: (_) => PlatformTransformer(),
    ));

    if (!config.handleUncaughtErrors) {
      await _platform.initialize(config: config);
      await appRunner();
      return;
    }

    await runZonedGuarded(() async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (error) async {
        FlutterError.presentError(error);
        Rollbar.error(error.exception, error.stack ?? StackTrace.empty);
      };

      await _platform.initialize(config: config);
      await appRunner();
    }, (exception, stackTrace) {
      Rollbar.error(exception, stackTrace);
    });
  }
}
