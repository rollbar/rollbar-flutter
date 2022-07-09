import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:meta/meta.dart';

import '../../rollbar.dart';
import 'core_notifier.dart';

/// This class handles the lifecycle of an uncaught error handler [Isolate].
/// Since isolates cannot share state, the error handler initialises its
/// own [CoreNotifier] instance, with the configuration provided.
class UncaughtErrorHandler {
  static late final SendPort sendPort;
  static late final CoreNotifier notifier;
  static late final PayloadProcessing processor;

  static Future<void> start(
    Config config,
    CoreNotifier coreNotifier,
    PayloadProcessing payloadProcessor,
  ) async {
    processor = payloadProcessor;

    final receivePort = ReceivePort();
    notifier = coreNotifier;

    final isolate = await Isolate.spawn(
      _handleError,
      receivePort.sendPort,
      paused: true,
    );

    sendPort = await receivePort.first;
    isolate.addErrorListener(sendPort);
    isolate.resume(isolate.pauseCapability!);
  }

  @protected
  static Future<void> _handleError(SendPort sendPort) async {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    await for (final message in receivePort) {
      try {
        final error = _getError(message[0]);
        final trace = _getTrace(message[1]);
        log('UncaughtErrorHandler._handleError got error: $error).');
        await notifier.log(Level.error, error, trace, null, processor);
      } on Exception catch (e) {
        log('Failed to process rollbar error message: $e');
      }
    }
  }

  static StackTrace? _getTrace(dynamic trace) {
    switch (trace.runtimeType) {
      case StackTrace:
        return trace;
      case String:
        return StackTrace.fromString(trace);
      default:
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
    final match = _exceptionClassPattern.firstMatch(error);
    if (match == null) return error;

    final exceptionPart = match.group(0)!;

    // `length - 1` to remove colon
    final clazz = exceptionPart.substring(0, exceptionPart.length - 1).trim();
    final message = error.substring(exceptionPart.length).trim();

    return ExceptionInfo()
      ..clazz = clazz
      ..message = message;
  }
}
