import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:developer';

import 'package:meta/meta.dart';
import 'package:rollbar_dart/rollbar.dart';
import 'package:rollbar_dart/src/data/response.dart';

const endpointPrefix = 'http://raw:';

typedef JsonMap = Map<String, dynamic>;

extension Port on Config {
  int get port => int.parse(endpoint.substring(endpointPrefix.length));
}

/// Useful class to do some basic tests across isolates, without setting up a
/// full blown HTTP server. It accepts and collects raw text over a TCP socket,
/// 1 message per line.
class RawTextSocket {
  late Isolate _isolate;
  late ReceivePort _receivePort;
  int port = 0;

  RawTextSocket._();

  String get endpoint => '$endpointPrefix$port';

  Future<void> _start() async {
    _receivePort = ReceivePort();

    final tcpInfoPort = ReceivePort();

    _isolate = await Isolate.spawn(
        _server, [tcpInfoPort.sendPort, _receivePort.sendPort]);

    port = await tcpInfoPort.first;
    tcpInfoPort.close();
  }

  /// Returns the messages received. This will block, so normally you'll want to
  /// do something like
  /// `var message = await server.messages.first.timeout(Duration(milliseconds: 500));`
  /// ...with an appropriate timeout for the scenario being tested.
  Stream<String?> get messages =>
      _receivePort.map((message) => message as String?);

  Future<void> close() async {
    final socket = await Socket.connect('localhost', port);
    try {
      socket.add('close\n'.codeUnits);
    } finally {
      socket.destroy();
    }

    _receivePort.close();

    _isolate.kill(priority: Isolate.beforeNextEvent);
  }

  static Future<RawTextSocket> build() async {
    final socket = RawTextSocket._();
    await socket._start();
    return socket;
  }

  static Future<void> _server(List<SendPort> ports) async {
    final serverSocket = await ServerSocket.bind('127.0.0.1', 0);

    final tcpInfo = ports[0];
    final msgPort = ports[1];

    tcpInfo.send(serverSocket.port);

    await for (final socket in serverSocket) {
      log('New connection from ${socket.remotePort}');
      socket
          .map((event) => event.toList())
          .transform(utf8.decoder)
          .transform(LineSplitter())
          .listen((msg) {
        msgPort.send(msg);
        if (msg == 'close') {
          socket.close();
          serverSocket.close();
        }
      });
    }

    log('Server method finished');
  }
}

/// A `Sender` implementation that can send occurrences to a `RawTextSocket`
/// instance over a TCP connection.
@immutable
class RawTextSender implements Sender {
  final int port;

  RawTextSender(Config config) : port = config.port;

  @override
  Future<bool> send(JsonMap payload) async =>
      await sendString(jsonEncode(payload));

  @override
  Future<bool> sendString(String payload) async {
    final socket = await Socket.connect('localhost', port);
    log('Client connected with port ${socket.port}');
    try {
      socket.add('${payload.replaceAll('\n', ' ')}\n'.codeUnits);
    } finally {
      socket.destroy();
    }

    return !Response(error: 0, result: Result(uuid: '1234')).isError;
  }
}
