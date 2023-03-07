import 'dart:async';
import 'dart:isolate';

import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';
import 'package:rollbar_dart/rollbar_dart.dart';
import 'package:rollbar_dart/src/data/event.dart';

/// An asynchronous notifier that leverages Dart's Isolated execution contexts
/// to achieve asynchrony via a separate thread.
@sealed
@immutable
@internal
class IsolatedSandbox implements Sandbox<Context, Event> {
  final SendPort _sendPort;
  final ReceivePort _receivePort;
  final Isolate _isolate;

  @override
  Future<Context> get state async {
    _sendPort.send(ContextSnapshot());
    return await _receivePort.where((e) => e is Context).cast().first;
  }

  IsolatedSandbox._(
    this._isolate,
    this._receivePort,
    this._sendPort,
  );

  @override
  void dispatch(final Event action) {
    _sendPort.send(action);
  }

  @override
  void dispose() {
    _receivePort.close();
    _isolate.kill(priority: Isolate.beforeNextEvent);
  }

  static Future<IsolatedSandbox> spawn(final Config config) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
        _IsolatedSandbox$Isolate.run, Tuple2(receivePort.sendPort, config),
        paused: false,
        errorsAreFatal: true,
        debugName: 'IsolatedSandbox\$Isolate');
    final sendPort = await receivePort.first;

    return IsolatedSandbox._(isolate, receivePort, sendPort);
  }
}

extension _IsolatedSandbox$Isolate on IsolatedSandbox {
  static Future<void> run(final Tuple2<SendPort, Config> pair) async {
    final sendPort = pair.first;
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    final config = pair.second;
    final context = Context(config);
    final notifier = config.notifier(config);

    await for (final event in receivePort) {
      switch (event.runtimeType) {
        case ContextSnapshot:
          sendPort.send(context);
          break;
        default:
          await notifier.notify(context, event);
      }
    }

    receivePort.close();
  }
}
