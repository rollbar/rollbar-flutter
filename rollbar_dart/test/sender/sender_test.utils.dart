import 'package:rollbar_common/src/http.dart';
import 'package:rollbar_dart/src/config.dart';

class Expected {
  static String uuidString = '67ce3d7bfab14fd99218ae5c985071e7';

  final Config config;

  const Expected(this.config);

  Uri get endpoint => Uri.parse(config.endpoint);

  String get successBody => '''{
    "err": 0,
    "result": {
      "uuid": "$uuidString"
    }
  }''';

  String get failureBody => '''{
    "err": 1,
    "message": "invalid format"
  }''';

  String get emptyBody => '';

  HttpHeaders get headers => {
        'User-Agent': 'rollbar-dart',
        'Content-Type': 'application/json',
        'X-Rollbar-Access-Token': config.accessToken,
      };

  String get payload => '''{
        "data":{
          "body":{
            "telemetry":[{
              "type":"navigation",
              "level":"info",
              "source":"client",
              "timestamp_ms":1668254707064529,
              "body":{
                "from":"initialize",
                "to":"runApp"
              }
            }],
            "message":{
              "body":"Rollbar initialized"
            }
          },
          "notifier":{
            "version":"1.0.0",
            "name":"rollbar-dart"
          },
          "environment":"development",
          "client":{
            "locale":"und",
            "hostname":"Hetfield",
            "os":"ios",
            "os_version":"Version 16.1 (Build 20B72)",
            "dart":{
              "version":"2.18.4 (stable) (Tue Nov 1 15:15:07 2022 +0000) on \\"ios_x64\\""
            },
            "number_of_processors":10
          },
          "platform":"ios",
          "language":"dart",
          "level":"info",
          "timestamp":1668254707501008,
          "server":{
            "root":"rollbar_flutter_example"
          },
          "framework":"flutter",
          "code_version":"main"
        }
      }''';
}
