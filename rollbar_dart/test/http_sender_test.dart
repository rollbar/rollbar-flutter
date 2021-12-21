import 'package:http/http.dart' as http;
import 'package:rollbar_dart/src/http_sender.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'http_sender_test.mocks.dart';

@GenerateMocks([http.Response])
void main() {
  group('Response conversion', () {
    test('Can convert successful API response', () async {
      var response = MockResponse();
      when(response.body).thenReturn('''{
    "err": 0,
    "result": {
        "id": null,
        "uuid": "67ce3d7bfab14fd99218ae5c985071e7"
    }
}''');
      var rollbarResponse = await toRollbarResponse(Future.value(response));

      expect(rollbarResponse.err, equals(0));
      expect(rollbarResponse.result, isNotNull);
      expect(rollbarResponse.result!.uuid,
          equals('67ce3d7bfab14fd99218ae5c985071e7'));
    });

    test('Can convert error API response', () async {
      var response = MockResponse();
      when(response.body).thenReturn('''{
    "err": 1,
    "message": "invalid token"
}''');
      var rollbarResponse = await toRollbarResponse(Future.value(response));

      expect(rollbarResponse.err, equals(1));
      expect(rollbarResponse.message, equals('invalid token'));
      expect(rollbarResponse.result, isNull);
    });
  });
}
