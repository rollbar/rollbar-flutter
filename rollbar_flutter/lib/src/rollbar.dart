import 'dart:async';
import 'dart:developer';
//import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rollbar_dart/rollbar.dart';

import 'platform_transformer.dart';

/// Rollbar Flutter notifier.
class RollbarFlutter extends Rollbar {
  static const MethodChannel _channel = MethodChannel('rollbar_flutter');
  final UniqueKey instanceId;

  RollbarFlutter._(Config config)
      : instanceId = UniqueKey(),
        super(Config.from(config,
            framework: 'flutter', transformer: platformTransformer));

  static Future<RollbarFlutter> start(Config config) async {
    final rollbar = RollbarFlutter._(config);

    if (!config.handleUncaughtErrors) {
      await rollbar._initializePlatformInstance();
      return rollbar;
    }

    await runZonedGuarded(() async {
      WidgetsFlutterBinding.ensureInitialized();

      final previousOnError = FlutterError.onError;
      FlutterError.onError = (error) async {
        await rollbar.error(error.exception, error.stack ?? StackTrace.empty);
        previousOnError?.call(error);
      };

      // final errorHandler = await (rollbar.errorHandler as Future<SendPort?>);
      // if (errorHandler == null) return;

      // Isolate.current.addErrorListener(errorHandler);

      await rollbar._initializePlatformInstance();
      //await then(rollbar);
    }, (exception, StackTrace trace) {
      rollbar.error(exception, trace);
    });

    return rollbar;
  }

  Future<void> _initializePlatformInstance() async {
    WidgetsFlutterBinding.ensureInitialized();

    await _channel.invokeMethod('initialize', <String, dynamic>{
      'instanceId': instanceId.toString(),
      'isGlobalInstance': true,
      'endpoint': config.endpoint,
      'accessToken': config.accessToken,
      'environment': config.environment,
      'codeVersion': config.codeVersion,
      'handleUncaughtErrors': config.handleUncaughtErrors,
      'includePlatformLogs': config.includePlatformLogs
    });
  }
}
