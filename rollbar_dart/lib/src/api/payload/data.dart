import 'body.dart' show Body;
import 'client.dart' show Client;
import 'level.dart';

/// Contains the data for the occurrence to be sent to Rollbar.
class Data {
  Map<String, String> notifier;
  String environment;
  Client client;
  String platform;
  String language;
  String framework;
  Level level;
  int timestamp;
  Body body;
  Map<String, Object> custom;

  Map platformPayload;

  Map<String, dynamic> toJson() {
    var result = {
      'notifier': notifier,
      'environment': environment,
      'client': client.toJson(),
      'platform': platform,
      'language': language,
      'framework': framework,
      'level': level.name,
      'timestamp': timestamp,
      'body': body.toJson(),
      'custom': custom,
    };

    if (platformPayload != null) {
      result['platform_payload'] = platformPayload;
    }

    return result;
  }
}
