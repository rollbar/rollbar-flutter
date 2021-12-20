import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:rollbar_dart/rollbar.dart';
import 'package:rollbar_dart/src/uncaught_error.dart';
import 'package:test/test.dart';

import 'client_server_utils.dart';

void main() {
  group('UncaughtErrorHandler tests', () {
    late RawTextSocket _server;
    late UncaughtErrorHandler _handler;

    setUp(() async {
      _server = await RawTextSocket.build();
      _handler = await _createErrorHandler(_server.endpoint);
    });

    tearDown(() async {
      await _server.close();
    });

    test(
        'When error is received in current isolate should report it using sender',
        () async {
      var errorPort = await _handler.errorHandlerPort;
      try {
        await throwyMethodA();
      } catch (error, trace) {
        errorPort!.send([error.toString(), trace.toString()]);
      }

      var payloadJson =
          await _server.messages.first.timeout(Duration(milliseconds: 500));
      expect(payloadJson != null, equals(true));
      var payload = json.decode(payloadJson!);

      var data = payload['data'];
      expect(data['language'], equals('dart'));

      var frames = data['body']['trace']['frames'];
      // We'll get different traces depending on whether we're running in AOT
      // or VM modes, and there isn't much we can do about it. So the only
      // thing we can reliably check here is the first element
      expect(frames[0]['method'], equals('nestedThrowy'));
    });

    test(
        'When error is not caught in separate isolate should report it using sender',
        () async {
      var errorPort = await _handler.errorHandlerPort;
      var isolate = await Isolate.spawn(secondIsolateMethod, errorPort);
      try {
        var payloadJson =
            await _server.messages.first.timeout(Duration(milliseconds: 500));
        expect(payloadJson != null, equals(true));
        var payload = json.decode(payloadJson!);

        var data = payload['data'];
        expect(data['language'], equals('dart'));

        var frames = data['body']['trace']['frames'];
        expect(frames[0]['method'], equals('inDifferentIsolate'));

        var message = data['body']['trace']['exception']['message'];
        expect(message, equals('Too late'));
      } finally {
        isolate.kill();
      }
    });
  });
}

Future<void> throwyMethodA() async {
  await nestedThrowy();
}

Future<void> nestedThrowy() async {
  await Future.delayed(Duration(milliseconds: 1));
  throw TimeoutException('Too late');
}

Future<void> inDifferentIsolate() async {
  await Future.delayed(Duration(milliseconds: 1));
  throw TimeoutException('Too late');
}

Future<UncaughtErrorHandler> _createErrorHandler(String endpoint) async {
  var config = (ConfigBuilder('BlaBlaAccessToken')
        ..endpoint = endpoint
        ..environment = 'production'
        ..codeVersion = '1.0.0'
        ..handleUncaughtErrors = true
        ..sender = createTextSender)
      .build();

  return await UncaughtErrorHandler.build(config);
}

Future<void> secondIsolateMethod(SendPort? errorPort) async {
  Isolate.current.addErrorListener(errorPort!);
  // No try catch here, our handler should take care of it
  await inDifferentIsolate();
}
