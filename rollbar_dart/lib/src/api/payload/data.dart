import '../../ext/collections.dart';
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

  JsonMap toMap() => {
        'notifier': notifier,
        'environment': environment,
        'client': client.toMap(),
        'platform': platform,
        'language': language,
        'level': level?.name,
        'timestamp': timestamp,
        'body': body.toMap(),
        'custom': custom,
        'server': server,
        'framework': framework,
        'code_version': codeVersion,
        'platform_payload': platformPayload,
      }..removeWhere((key, value) => value == null);
}
