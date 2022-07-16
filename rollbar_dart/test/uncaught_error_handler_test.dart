import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:rollbar_dart/rollbar.dart';
import 'package:rollbar_dart/src/uncaught_error_handler.dart';
import 'package:test/test.dart';

import 'client_server_utils.dart';

Future<void> main() async {
  group('UncaughtErrorHandler tests', () {
    late RawTextSocket server;
    // ignore: deprecated_member_use_from_same_package
    late UncaughtErrorHandler handler;

    setUp(() async {
      server = await RawTextSocket.build();

      final config = Config(
          accessToken: 'BlaBlaAccessToken',
          endpoint: server.endpoint,
          environment: 'production',
          package: 'some_package_name',
          codeVersion: '1.0.0',
          handleUncaughtErrors: true,
          sender: createTextSender);

      // ignore: deprecated_member_use_from_same_package
      handler = await UncaughtErrorHandler.run(config: config);
    });

    tearDown(() async {
      await server.close();
      handler.dispose();
    });

    test('Reporting error caught in current isolate using sender', () async {
      try {
        await throwyMethodA();
      } catch (error, stackTrace) {
        handler.sendPort.send([error.toString(), stackTrace.toString()]);
      }

      final payloadJson = await server.messages.first;
      expect(payloadJson, isNotNull);
      final payload = jsonDecode(payloadJson!);

      final data = payload['data'];
      expect(data['language'], equals('dart'));

      final frames = data['body']['trace']['frames'];
      // We'll get different traces depending on whether we're running in AOT
      // or VM modes, and there isn't much we can do about it. So the only
      // thing we can reliably check here is the first element
      expect(frames.first['method'], equals('nestedThrowy'));
    });

    test('Report uncaught error in separate isolate using sender', () async {
      final isolate = await Isolate.spawn(otherIsolateMethod, handler.sendPort);
      try {
        final payloadJson = await server.messages.first;
        expect(payloadJson, isNotNull);
        final payload = jsonDecode(payloadJson!);

        final data = payload['data'];
        expect(data['language'], equals('dart'));

        final frames = data['body']['trace']['frames'];
        expect(frames[0]['method'], equals('inDifferentIsolate'));

        final message = data['body']['trace']['exception']['message'];
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

Future<void> otherIsolateMethod(SendPort errorPort) async {
  Isolate.current.addErrorListener(errorPort);
  // No try catch here, our handler should take care of it
  await inDifferentIsolate();
}
