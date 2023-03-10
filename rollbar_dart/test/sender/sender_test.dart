import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:rollbar_dart/src/data/config.dart';
import 'package:rollbar_dart/src/sender/http_sender.dart';
import 'package:rollbar_dart/src/sender/persistent_http_sender.dart';

import 'sender_test.mocks.dart';
import 'sender_test.utils.dart';

@GenerateMocks([http.Client])
Future<void> main() async {
  group('HTTP transport via Senders', () {
    test('HTTP Sender posts appropriately and succeeds', () async {
      final client = MockClient();
      final config = Config(accessToken: '012345678', httpClient: () => client);
      final expected = Expected(config);
      final sender = HttpSender(config);

      when(client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer(
        (_) async => http.Response(expected.successBody, 200),
      );

      expect(await sender.sendString(expected.payload), isTrue);

      verifyInOrder([
        client.post(
          expected.endpoint,
          headers: expected.headers,
          body: expected.payload,
        ),
        client.close(),
      ]);

      verifyNoMoreInteractions(client);
    });

    test('HTTP Sender posts appropriately and fails', () async {
      final client = MockClient();
      final config = Config(accessToken: '012345678', httpClient: () => client);
      final expected = Expected(config);
      final sender = HttpSender(config);

      when(client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer(
        (_) async => http.Response(expected.failureBody, 422),
      );

      expect(await sender.sendString(expected.payload), isFalse);

      verifyInOrder([
        client.post(
          expected.endpoint,
          headers: expected.headers,
          body: expected.payload,
        ),
        client.close(),
      ]);

      verifyNoMoreInteractions(client);
    });
  });

  group('Persistent HTTP transport via Senders', () {
    test('Persistent HTTP Sender posts appropriately and succeeds', () async {
      final client = MockClient();
      final config = Config(accessToken: '012345678', httpClient: () => client);
      final expected = Expected(config);
      final sender = PersistentHttpSender(config);

      when(client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer(
        (_) async => http.Response(expected.successBody, 200),
      );

      expect(await sender.sendString(expected.payload), isTrue);
      expect(sender.records.isEmpty, isTrue);

      verifyInOrder([
        client.post(
          expected.endpoint,
          headers: expected.headers,
          body: expected.payload,
        ),
        client.close(),
      ]);

      verifyNoMoreInteractions(client);
    });

    test('Persistent HTTP Sender posts but server is unavailable', () async {
      final client = MockClient();
      final config = Config(accessToken: '012345678', httpClient: () => client);
      final expected = Expected(config);
      final sender = PersistentHttpSender(config);

      when(client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer(
        (_) async => http.Response(expected.emptyBody, 503),
      );

      expect(await sender.sendString(expected.payload), isFalse);
      expect(sender.records.isEmpty, isFalse);
      sender.records.clear();
      expect(sender.records.isEmpty, isTrue);

      verifyInOrder([
        client.post(
          expected.endpoint,
          headers: expected.headers,
          body: expected.payload,
        ),
        client.close(),
      ]);

      verifyNoMoreInteractions(client);
    });
  });
}
