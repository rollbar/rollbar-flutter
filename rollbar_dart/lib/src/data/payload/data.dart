import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

import 'body.dart' show Body;
import 'client.dart' show Client;
import 'user.dart' show User;

/// Contains the data for the occurrence to be sent to Rollbar.
@sealed
@immutable
class Data with EquatableSerializableMixin implements Serializable, Equatable {
  final Body body;
  final Level level;
  final JsonMap notifier;
  final String environment;
  final Client client;
  final String platform;
  final String language;
  final String framework;
  final String codeVersion;
  final User? user;
  final JsonMap? custom;
  final JsonMap? platformPayload;
  final JsonMap server;
  final DateTime timestamp;

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
    this.user,
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
    DateTime? timestamp,
    Body? body,
    User? user,
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
        user: user ?? this.user,
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
      user: other.user,
      custom: other.custom,
      platformPayload: other.platformPayload,
      server: other.server);

  factory Data.fromMap(JsonMap map) => Data(
      notifier: map['notifier'],
      environment: map['environment'],
      client: Client.fromMap(map['client']),
      platform: map['platform'],
      language: map['language'],
      framework: map['framework'],
      codeVersion: map['code_version'],
      level: Level.values.firstWhere((level) => level.name == map['level']),
      body: Body.fromMap(map['body']),
      user: User.fromMap(map['person']),
      custom: map['custom'],
      platformPayload: map['platform_payload'],
      server: map['server'],
      timestamp: DateTime.fromMicrosecondsSinceEpoch(
        map['timestamp'],
        isUtc: true,
      ));

  @override
  JsonMap toMap() => {
        'body': body.toMap(),
        'notifier': notifier,
        'environment': environment,
        'client': client.toMap(),
        'platform': platform,
        'language': language,
        'level': level.name,
        'timestamp': timestamp.microsecondsSinceEpoch,
        'person': user,
        'custom': custom,
        'server': server,
        'framework': framework,
        'code_version': codeVersion,
        'platform_payload': platformPayload,
      }.compact();
}
