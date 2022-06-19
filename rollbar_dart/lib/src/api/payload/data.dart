import 'body.dart' show Body;
import 'client.dart' show Client;
import 'level.dart';

/// Contains the data for the occurrence to be sent to Rollbar.
class Data {
  late Map<String, String> notifier;
  String? environment;
  late Client client;
  String? platform;
  late String language;
  String? framework;
  String? codeVersion;
  Level? level;
  int? timestamp;
  late Body body;
  Map<String, Object>? custom;
  Map? platformPayload;
  Map? server;

  Map<String, dynamic> toJson() {
    final result = {
      'notifier': notifier,
      'environment': environment,
      'client': client.toJson(),
      'platform': platform,
      'language': language,
      'level': level.name,
      'timestamp': timestamp,
      'body': body.toJson(),
    };

    if (custom != null) result['custom'] = custom;
    if (server != null) result['server'] = server;
    if (framework != null) result['framework'] = framework;
    if (codeVersion != null) result['code_version'] = codeVersion;
    if (platformPayload != null) result['platform_payload'] = platformPayload;

    return result;
  }
}
