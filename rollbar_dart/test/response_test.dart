import 'dart:convert';

import 'package:rollbar_common/rollbar_common.dart';
import 'package:rollbar_dart/src/data/response.dart';
import 'package:test/test.dart';

void main() {
  group('Response Serialization tests', () {
    test('Json roundtrip serialization test', () {
      final response = Response(
          error: 1,
          message: 'error',
          result: UUID('67ce3d7b-fab1-4fd9-9218-ae5c985071e7'));

      final asJson = jsonEncode(response.toMap());
      final map = jsonDecode(asJson);
      final recovered = Response.fromMap(map);

      expect(recovered.error, equals(response.error));
      expect(recovered.message, equals(response.message));
      expect(recovered.result, equals(response.result));
    });

    test('Serialization is null-safe test', () {
      final response = Response(
          error: 0,
          message: null,
          result: UUID('67ce3d7b-fab1-4fd9-9218-ae5c985071e7'));
      final asJson = jsonEncode(response.toMap());
      final recovered = Response.fromMap(jsonDecode(asJson));

      expect(recovered.error, equals(response.error));
      expect(recovered.message, equals(response.message));
      expect(recovered.result, equals(response.result));

      final response2 = Response(error: 1, message: '', result: null);
      final asJson2 = jsonEncode(response2.toMap());
      final recovered2 = Response.fromMap(jsonDecode(asJson2));

      expect(recovered2.error, equals(response2.error));
      expect(recovered2.message, equals(response2.message));
      expect(recovered2.result, equals(response2.result));
    });
  });
}
