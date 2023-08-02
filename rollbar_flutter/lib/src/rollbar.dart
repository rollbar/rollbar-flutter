import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'package:rollbar_dart/rollbar.dart';

import 'hooks/hook.dart';
import 'hooks/flutter_hook.dart';
import 'hooks/platform_hook.dart';
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
@immutable
class RollbarFlutter {
  static const _platform = MethodChannel('com.rollbar.flutter');

  const RollbarFlutter._();

  static Future<void> run(
    Config config,
    RollbarClosure appRunner,
  ) async {
    if (!config.handleUncaughtErrors) {
      await _run(config, appRunner);
    } else if (requiresCustomZone) {
      await runZonedGuarded(
          () async => await _run(config, appRunner, [FlutterHook()]),
          Rollbar.error);
    } else {
      await _run(config, appRunner, [FlutterHook(), PlatformHook()]);
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

    await _platform.initialize(config: config);
    await appRunner();
  }

  static bool get requiresCustomZone {
    try {
      (PlatformDispatcher.instance as dynamic)?.onError;
      return false;
    } on NoSuchMethodError {
      return true;
    }
  }
}
