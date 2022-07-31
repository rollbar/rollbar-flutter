import 'dart:async';
import 'dart:isolate';

import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';
import 'package:rollbar_dart/rollbar_dart.dart';
import 'async_notifier.dart';

/// An asynchronous notifier that leverages Dart's Isolated execution contexts
/// to achieve asynchrony via a separate thread.
@sealed
@immutable
class IsolatedNotifier implements AsyncNotifier {
  @override
  final Sender sender;

  @override
  final Wrangler wrangler;

  final SendPort _sendPort;
  final ReceivePort _receivePort;
  final Isolate _isolate;

  IsolatedNotifier._(
    Config config,
    this._isolate,
    this._receivePort,
    this._sendPort,
  )   : wrangler = config.wrangler(config),
        sender = config.sender(config);

  @override
  void notify(Event event) {
    _sendPort.send(event);
  }

  @override
  void dispose() {
    _receivePort.close();
    _isolate.kill(priority: Isolate.beforeNextEvent);
  }

  static Future<IsolatedNotifier> spawn(Config config) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
        _AsyncNotifier$Isolate.run, //
        Tuple2(receivePort.sendPort, config),
        debugName: 'AsyncNotifier\$Isolate');
    final sendPort = await receivePort.first;

    return IsolatedNotifier._(config, isolate, receivePort, sendPort);
  }
}

extension _AsyncNotifier$Isolate on IsolatedNotifier {
  static late final Wrangler wrangler;
  static late final Sender sender;

  static Future<void> run(Tuple2<SendPort, Config> tuple) async {
    final sendPort = tuple.first;
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    final config = tuple.second;
    sender = config.sender(config);
    wrangler = config.wrangler(config);

    await for (final Event event in receivePort) {
      final payload = await wrangler.payload(from: event);
      await sender.send(payload.toMap());
    }
  }
}
