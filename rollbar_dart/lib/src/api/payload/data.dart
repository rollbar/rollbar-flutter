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
  String codeVersion;
  Level level;
  int timestamp;
  Body body;
  Map<String, Object> custom;
  Map platformPayload;
  Map server;

  Map<String, dynamic> toJson() {
    var result = {
      'notifier': notifier,
      'environment': environment,
      'client': client.toJson(),
      'platform': platform,
      'language': language,
      'level': level.name,
      'timestamp': timestamp,
      'body': body.toJson(),
    };

    addIfNotNull(result, 'framework', framework);
    addIfNotNull(result, 'code_version', codeVersion);
    addIfNotNull(result, 'custom', custom);
    addIfNotNull(result, 'platform_payload', platformPayload);
    addIfNotNull(result, 'server', server);

    return result;
  }

  void addIfNotNull(Map<String, dynamic> result, String name, dynamic value) {
    if (value != null) {
      result[name] = value;
    }
  }
}
