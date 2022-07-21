import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:meta/meta.dart';

import 'ext/object.dart';
import 'ext/collections.dart';
import 'ext/tuple.dart';

import '../../rollbar.dart';
import 'core_notifier.dart';

/// This class handles the lifecycle of an uncaught error handler [Isolate].
/// Since isolates cannot share state, the error handler initialises its
/// own [CoreNotifier] instance, with the configuration provided.
///
/// [todo] remove this, uncaught errors should be handled through zone guards.
@Deprecated('soon')
class UncaughtErrorHandler {
  final ReceivePort _receivePort;
  final Isolate _isolate;

  final SendPort sendPort;

  UncaughtErrorHandler._(
    this._isolate,
    this._receivePort,
    this.sendPort,
  );

  void dispose() {
    _receivePort.close();
    _isolate.kill(priority: Isolate.beforeNextEvent);
  }

  static Future<UncaughtErrorHandler> run({required Config config}) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      work,
      Tuple2(receivePort.sendPort, config),
    );
    final sendPort = await receivePort.first;

    return UncaughtErrorHandler._(isolate, receivePort, sendPort);
  }

  @protected
  static Future<void> work(Tuple2<SendPort, Config> initial) async {
    final sendPort = initial.first;
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    final config = initial.second;
    final notifier = CoreNotifier(config: config);

    await for (var message in receivePort) {
      if (message is! List) throw ArgumentError('message must be a List');
      log('UncaughtErrorHandler got: ${message.error}'
          '\n${message.error.toString()}'
          '\n${message.trace}');
      await notifier.notify(Level.error, message.error, message.trace);
    }
  }
}

extension _TraceOrError<Object> on List<Object> {
  dynamic get error => tryElementAt(0).map(
        (error) => error is String ? error.toExceptionInfo() : error,
      );

  StackTrace? get trace => tryElementAt(1).flatMap(
        (trace) => trace is StackTrace
            ? trace
            : trace is String
                ? trace.toStackTrace()
                : null,
      );
}

extension _Error on String {
  StackTrace toStackTrace() {
    return StackTrace.fromString(this);
  }

  ExceptionInfo? toExceptionInfo() {
    return exceptionPattern
        .firstMatch(this)
        ?.group(0)
        .map((exception) => ExceptionInfo(
              type: exception.removeColon.trim(),
              message: substring(exception.length).trim(),
            ));
  }

  String get removeColon => substring(0, length - 1);

  static RegExp get exceptionPattern => RegExp(
      r'^\s*([a-z|_|\$][a-z|0-9|_|\$]*)(\.[a-z|_|\$][a-z|0-9|_|\$]*)*\s*:',
      caseSensitive: false);
}
