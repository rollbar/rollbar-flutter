import 'dart:convert';

import 'package:rollbar_dart/src/data/response.dart';
import 'package:test/test.dart';

void main() {
  group('Response Serialization tests', () {
    test('Json roundtrip serialization test', () {
      final response = Response(
        error: 1,
        message: 'error',
        result: Result(uuid: '1234'),
      );

      final asJson = jsonEncode(response.toMap());
      final map = jsonDecode(asJson);
      final recovered = Response.fromMap(map);

      expect(recovered.error, equals(response.error));
      expect(recovered.message, equals(response.message));
      expect(recovered.result, equals(response.result));
    });

    test('Serialization is null-safe test', () {
      final response = Response(error: 0, message: null, result: null);
      final asJson = jsonEncode(response.toMap());
      final recovered = Response.fromMap(jsonDecode(asJson));

      expect(recovered.error, equals(response.error));
      expect(recovered.message, equals(response.message));
      expect(recovered.result, equals(response.result));
    });
  });
}
