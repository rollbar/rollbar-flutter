import 'dart:convert';

import 'package:rollbar_common/src/record.dart';
import 'package:test/test.dart';

void main() {
  group('PayloadRecord serialization tests', () {
    test('Json roundtrip serialization test', () {
      final record = Record(
          accessToken: 'TOKEN1',
          endpoint: 'wwww.site.com',
          config: 'CONFIG1',
          payload: 'PAYLOAD1');

      final asMap = record.toMap();
      final asJson = jsonEncode(asMap);
      final recovered = Record.fromMap(jsonDecode(asJson));
      expect(recovered, equals(record));
      expect(recovered.id, equals(record.id));
      expect(recovered.timestamp, equals(record.timestamp));
      expect(recovered.accessToken, equals(record.accessToken));
      expect(recovered.endpoint, equals(record.endpoint));
      expect(recovered.payload, equals(record.payload));
    });
  });
}
