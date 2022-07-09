import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rollbar_dart/rollbar.dart';

import 'platform_transformer.dart';

extension _Methods on MethodChannel {
  Future<void> initialize({required Config config}) async =>
      await invokeMethod('initialize', config.toMap());
}

@sealed
class RollbarFlutter {
  static const platform = MethodChannel('com.rollbar.flutter');

  RollbarFlutter._();

  static Future<Rollbar> start({required Config config}) async {
    final rollbar = await Rollbar.start(
        config: config.copyWith(
            framework: 'flutter', transformer: platformTransformer));

    await platform.initialize(config: config);

    if (config.handleUncaughtErrors) {
      await runZonedGuarded(() async {
        WidgetsFlutterBinding.ensureInitialized();
        FlutterError.onError = (error) async {
          await rollbar.error(error.exception, error.stack ?? StackTrace.empty);
          FlutterError.presentError(error);
        };
      }, (exception, stackTrace) {
        rollbar.error(exception, stackTrace);
      });
    }

    return rollbar;
  }
}
