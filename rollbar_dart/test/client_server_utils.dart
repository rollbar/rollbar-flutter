import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:rollbar_dart/rollbar.dart';
import 'package:rollbar_dart/src/api/response.dart';

const endpointPrefix = 'http://raw:';

Sender createTextSender(Config c) {
  if (c.endpoint.startsWith(endpointPrefix)) {
    var port = int.parse(c.endpoint.substring(endpointPrefix.length));
    return RawTextSender(port);
  } else {
    throw Exception('Invalid endpoint ${c.endpoint}');
  }
}

/// Useful class to do some basic tests across isolates, without setting up a full blown
/// HTTP server. It accepts and collects raw text over a TCP socket, 1 message per line.
class RawTextSocket {
  late Isolate _isolate;
  int? _port;
  late ReceivePort _receivePort;

  RawTextSocket._();

  String get endpoint => '$endpointPrefix$port';

  Future<int?> _start() async {
    _receivePort = ReceivePort();

    var tcpInfoPort = ReceivePort();

    _isolate = await Isolate.spawn(
        _server, [tcpInfoPort.sendPort, _receivePort.sendPort]);

    var port = await tcpInfoPort.first;
    tcpInfoPort.close();

    return port;
  }

  int? get port {
    return _port;
  }

  /// Returns the messages received. This will block, so normally you'll want to
  /// do something like
  /// `var message = await server.messages.first.timeout(Duration(milliseconds: 500));`
  /// ...with an appropriate timeout for the scenario being tested.
  Stream<String?> get messages {
    return _receivePort.map((v) => v as String?);
  }

  Future<void> close() async {
    final socket = await Socket.connect('localhost', port!);
    try {
      socket.add('close\n'.codeUnits);
    } finally {
      socket.destroy();
    }

    _receivePort.close();

    _isolate.kill(priority: Isolate.beforeNextEvent);
  }

  static Future<RawTextSocket> build() async {
    var socket = RawTextSocket._();
    socket._port = await socket._start();
    return socket;
  }

  static Future<void> _server(List<SendPort> ports) async {
    var serverSocket = await ServerSocket.bind('127.0.0.1', 0);

    var tcpInfo = ports[0];
    var msgPort = ports[1];

    tcpInfo.send(serverSocket.port);

    await for (var socket in serverSocket) {
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
/// Since we can only pass static or free functions as messages between isolates,
/// the `sender` factory config parameter cannot be a closure.
/// So we can only instatiate a `Sender` based on the fields in our notifier `Config`
/// class, which means there's no way of passing a `SendPort` to the sender factory
/// for testing. But we can use the `endpoint` to pass socket connection params.
class RawTextSender implements Sender {
  int port;

  RawTextSender(this.port);

  @override
  Future<Response?> send(Map<String, dynamic>? payload) async {
    if (payload == null) {
      return null;
    }

    final socket = await Socket.connect('localhost', port);
    log('Client connected with port ${socket.port}');
    try {
      var message = json.encode(payload).replaceAll('\n', ' ');
      socket.add('$message\n'.codeUnits);
    } finally {
      socket.destroy();
    }

    return Response()
      ..err = 0
      ..result = (Result()..uuid = '1234');
  }
}

void log(String _ignored) {}
