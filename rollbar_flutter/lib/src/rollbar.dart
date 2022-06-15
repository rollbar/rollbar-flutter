import 'dart:async';
import 'dart:isolate';

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
        super(_initConfig(config));

  static Future<void> run(
    Config config,
    FutureOr<void> Function(RollbarFlutter) action,
  ) async {
    final shouldHandleUncaughtErrors = config.handleUncaughtErrors ?? false;

    if (!shouldHandleUncaughtErrors) {
      var rollbar = RollbarFlutter._(config);
      await rollbar._initializePlatformInstance();
      await action(rollbar);
      return;
    }

    var rollbar = RollbarFlutter._(config);

    await runZonedGuarded(() async {
      WidgetsFlutterBinding.ensureInitialized();

      var previousOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) async {
        final stackTrace = details.stack ?? StackTrace.empty;
        await rollbar._unhandledError(details.exception, stackTrace);
        previousOnError?.call(details);
      };

      var errorHandler = await (rollbar.errorHandler as Future<SendPort?>);
      if (errorHandler == null) return;

      Isolate.current.addErrorListener(errorHandler);

      await rollbar._initializePlatformInstance();
      await action(rollbar);
    }, (Object exception, StackTrace trace) {
      rollbar._unhandledError(exception, trace);
    });
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

  Future<void> _unhandledError(dynamic exception, StackTrace trace) async {
    try {
      await super.error(exception, trace);
    } on Exception catch (e) {
      Logging.err(
          'Internal error encountered while sending data to Rollbar', e);
    }
  }

  static Config _initConfig(Config config) {
    var builder = ConfigBuilder.from(config);
    builder.framework ??= 'flutter';

    return (builder..transformer = platformTransformer).build();
  }
}

/// Free function to create the transformer.
///
/// Free and static functions are the only way we can pass factories to
/// different isolates, which we need to be able to do to register uncaught
/// error handlers.
Transformer platformTransformer(Config config) => PlatformTransformer();
