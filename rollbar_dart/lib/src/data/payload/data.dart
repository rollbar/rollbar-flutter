import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

import 'body.dart' show Body;
import 'client.dart' show Client;

/// The level of an occurrence.
enum Level { debug, info, warning, error, critical }

/// Contains the data for the occurrence to be sent to Rollbar.
@sealed
@immutable
class Data {
  final JsonMap notifier;
  final String environment;
  final Client client;
  final String platform;
  final String language;
  final String framework;
  final String codeVersion;
  final Level level;
  final int timestamp;
  final Body body;
  final JsonMap? custom;
  final JsonMap? platformPayload;
  final JsonMap server;

  const Data({
    required this.notifier,
    required this.environment,
    required this.client,
    required this.platform,
    required this.language,
    required this.framework,
    required this.codeVersion,
    required this.level,
    required this.timestamp,
    required this.body,
    this.custom,
    this.platformPayload,
    required this.server,
  });

  Data copyWith({
    JsonMap? notifier,
    String? environment,
    Client? client,
    String? platform,
    String? language,
    String? framework,
    String? codeVersion,
    Level? level,
    int? timestamp,
    Body? body,
    JsonMap? custom,
    JsonMap? platformPayload,
    JsonMap? server,
  }) =>
      Data(
        notifier: notifier ?? this.notifier,
        environment: environment ?? this.environment,
        client: client ?? this.client,
        platform: platform ?? this.platform,
        language: language ?? this.language,
        framework: framework ?? this.framework,
        codeVersion: codeVersion ?? this.codeVersion,
        level: level ?? this.level,
        timestamp: timestamp ?? this.timestamp,
        body: body ?? this.body,
        custom: custom ?? this.custom,
        platformPayload: platformPayload ?? this.platformPayload,
        server: server ?? this.server,
      );

  /// Shallow copy
  factory Data.from(Data other) => Data(
      notifier: other.notifier,
      environment: other.environment,
      client: other.client,
      platform: other.platform,
      language: other.language,
      framework: other.framework,
      codeVersion: other.codeVersion,
      level: other.level,
      timestamp: other.timestamp,
      body: other.body,
      custom: other.custom,
      platformPayload: other.platformPayload,
      server: other.server);

  JsonMap toMap() => {
        'notifier': notifier,
        'environment': environment,
        'client': client.toMap(),
        'platform': platform,
        'language': language,
        'level': level.name,
        'timestamp': timestamp,
        'body': body.toMap(),
        'custom': custom,
        'server': server,
        'framework': framework,
        'code_version': codeVersion,
        'platform_payload': platformPayload,
      }..removeWhere((key, value) => value == null);
}
