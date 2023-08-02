import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'package:rollbar_dart/rollbar.dart';

import 'hooks/hook.dart';
import 'hooks/flutter_hook.dart';
import 'hooks/platform_hook.dart';
import 'hooks/native_hook.dart';
import 'platform_transformer.dart';
import 'method_channel.dart';

typedef RollbarClosure = FutureOr<void> Function();

@sealed
@immutable
class RollbarFlutter {
  static const _platform = MethodChannel('com.rollbar.flutter');

  const RollbarFlutter._();

  static Future<void> run(
    Config config,
    RollbarClosure appRunner,
  ) async {
    if (!config.handleUncaughtErrors) {
      await _run(config, appRunner, [NativeHook()]);
    } else if (!PlatformHook.isAvailable) {
      await runZonedGuarded(
          () async => await _run(config, appRunner, [
                FlutterHook(),
                NativeHook(),
              ]),
          Rollbar.error);
    } else {
      await _run(config, appRunner, [
        FlutterHook(),
        PlatformHook(),
        NativeHook(),
      ]);
    }
  }

  static Future<void> _run(
    Config config,
    RollbarClosure appRunner, [
    List<Hook> hooks = const [],
  ]) async {
    WidgetsFlutterBinding.ensureInitialized();

    await Rollbar.run(config.copyWith(
      framework: 'flutter',
      persistencePath: await _platform.persistencePath,
      transformer: (_) => PlatformTransformer(),
    ));

    for (final hook in hooks) {
      await hook.install(config);
    }

    await appRunner();
  }
}
