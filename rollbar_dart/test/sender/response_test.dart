import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:http/http.dart';

import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:rollbar_common/src/http.dart';
import 'package:rollbar_common/src/identifiable.dart';
import 'package:rollbar_dart/src/data/response.dart';

import 'response_test.mocks.dart';

@GenerateMocks([Response])
void main() {
  group('API Response representation', () {
    test('Can represent an API success response', () {
      const statusCode = 200, reason = 'OK';

      final response = MockResponse();
      when(response.statusCode).thenReturn(statusCode);
      when(response.reasonPhrase).thenReturn(reason);
      when(response.body).thenReturn(Body.success);

      expect(response.statusCode, statusCode);
      expect(response.status, HttpStatus.success);
      expect(response.body, Body.success);
      expect(response.result.isSuccess, isTrue);
      expect(response.result.isFailure, isFalse);
      expect(response.result.success, Body.uuidString.toUUID());
    });

    test('Can represent an API failure response', () {
      const statusCode = 422, reason = 'Unprocessable Entity';

      final response = MockResponse();
      when(response.statusCode).thenReturn(statusCode);
      when(response.reasonPhrase).thenReturn(reason);
      when(response.body).thenReturn(Body.failure);

      expect(response.statusCode, statusCode);
      expect(response.status, HttpStatus.clientError);
      expect(response.body, Body.failure);
      expect(response.result.isSuccess, isFalse);
      expect(response.result.isFailure, isTrue);
      expect(response.result.failure.code, 1);
      expect(response.result.failure.message, 'invalid format');
    });

    test('Can represent an HTTP failure response', () {
      const statusCode = 503, reason = 'Service Unavailable';

      final response = MockResponse();
      when(response.statusCode).thenReturn(statusCode);
      when(response.reasonPhrase).thenReturn(reason);
      when(response.body).thenReturn(Body.empty);

      expect(response.statusCode, statusCode);
      expect(response.status, HttpStatus.serverError);
      expect(response.body, Body.empty);
      expect(response.result.isSuccess, isFalse);
      expect(response.result.isFailure, isTrue);
      expect(response.result.failure.code, statusCode);
      expect(response.result.failure.message, reason);
    });
  });
}

@internal
class Body {
  static String uuidString = '67ce3d7bfab14fd99218ae5c985071e7';

  static String empty = '';

  static String success = '''{
    "err": 0,
    "result": {
      "uuid": "$uuidString"
    }
  }''';

  static String failure = '''{
    "err": 1,
    "message": "invalid format"
  }''';
}
