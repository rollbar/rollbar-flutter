import 'dart:convert';
import 'dart:html_common';

import 'package:rollbar/rollbar.dart';
import 'package:test/test.dart';

void main() {
  group('Basic tests', () {
    Rollbar rollbar;
    setUp(() {
      var config = Config('BlaBlaAccessToken', 'production', '1.0.0');
      rollbar = Rollbar(config);
    });

    test('First test with invalid access token', () async {
      try {
        throw ArgumentError('Test error');
      } catch (error, stackTrace) {
        final response = await rollbar.error(error, stackTrace);
        Map<String, dynamic> map = json.decode(response.body);
        expect(map['message'], 'invalid access token');
      }
    });
  });
}
