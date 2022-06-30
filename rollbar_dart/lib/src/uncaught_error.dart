import 'dart:isolate';
import 'dart:async';

import 'package:rollbar_dart/rollbar_dart.dart';

import 'core_notifier.dart';

/// This class handles the lifecycle of an uncaught error handler [Isolate].
/// Since isolates cannot share state, the error handler initialises its
/// own [CoreNotifier] instance, with the configuration provided.
class UncaughtErrorHandler {
  Config _config;

  late Future<SendPort?> _errorPort;

  UncaughtErrorHandler._(this._config) {
    _errorPort = _getErrorMessageHandler(_config);
  }

  static Future<UncaughtErrorHandler> build(Config config) async {
    final handler = UncaughtErrorHandler._(config);

    if (config.handleUncaughtErrors!) {
      var errorPort = await handler._errorPort;
      if (errorPort != null) {
        Isolate.current.addErrorListener(errorPort);
      }
    }

    return handler;
  }

  Future<SendPort?> get errorHandlerPort {
    return _errorPort;
  }

  Future<void> configure(Config config) async {
    _config = config;
    var port = await errorHandlerPort;
    if (port != null) {
      port.send(_config);
    } else {
      _errorPort = _getErrorMessageHandler(_config);
    }
  }

  Future<SendPort?> _getErrorMessageHandler(Config config) async {
    if (config.handleUncaughtErrors!) {
      var receivePort = ReceivePort();
      await Isolate.spawn(_handleError, receivePort.sendPort);
      var errorPort = await receivePort.first;

      errorPort.send(config.toMap());

      return errorPort;
    } else {
      return null;
    }
  }

  static Future<void> _handleError(SendPort sendPort) async {
    try {
      var port = ReceivePort();

      sendPort.send(port.sendPort);

      CoreNotifier? rollbarCore;

      await for (var msg in port) {
        try {
          if (msg is Map<String, dynamic>) {
            final rollbarConfig = Config.fromMap(msg);
            await RollbarInfrastructure.instance
                .initialize(rollbarConfig: rollbarConfig);
            rollbarCore = CoreNotifier(rollbarConfig);
          } else {
            var error = _getError(msg[0]);
            if (rollbarCore != null) {
              var trace = _getTrace(msg[1]);
              await rollbarCore.log(Level.error, error, trace, null);
            } else {
              Logging.warn(
                  'An error has been reported to the uncaught error handler before the Rollbar instance was configured',
                  error);
            }
          }
        } on Exception catch (e) {
          Logging.err('Failed to process rollbar error message', e);
        }
      }
    } on Exception catch (e) {
      Logging.err('The rollbar uncaught error handler has crashed', e);
    }
  }

  static StackTrace? _getTrace(dynamic trace) {
    if (trace is StackTrace) {
      return trace;
    } else if (trace is String) {
      return StackTrace.fromString(trace);
    } else {
      return null;
    }
  }

  static dynamic _getError(dynamic error) {
    if (error is String) {
      return _tryParseError(error);
    } else {
      return error;
    }
  }

  static final RegExp _exceptionClassPattern = RegExp(
      r'^\s*([a-z|_|\$][a-z|0-9|_|\$]*)(\.[a-z|_|\$][a-z|0-9|_|\$]*)*\s*:',
      caseSensitive: false);

  static dynamic _tryParseError(String error) {
    var match = _exceptionClassPattern.firstMatch(error);
    if (match != null) {
      var exceptionPart = match.group(0)!;

      // `length - 1` to remove colon
      var clazz = exceptionPart.substring(0, exceptionPart.length - 1).trim();
      var message = error.substring(exceptionPart.length).trim();

      return ExceptionInfo()
        ..clazz = clazz
        ..message = message;
    } else {
      return error;
    }
  }
}
