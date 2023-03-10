import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

import 'body.dart' show Body;
import 'client.dart' show Client;
import 'user.dart' show User;

/// Contains the data for the occurrence to be sent to Rollbar.
@sealed
@immutable
class Data
    with EquatableSerializableMixin, DebugStringRepresentation
    implements Serializable, Equatable {
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

  factory Data.fromMap(JsonMap json) => Data(
      notifier: json.notifier,
      environment: json.environment,
      client: json.client,
      platform: json.platform,
      language: json.language,
      framework: json.framework,
      codeVersion: json.codeVersion,
      level: json.level,
      body: json.body,
      user: json.user,
      custom: json.custom,
      platformPayload: json.platformPayload,
      server: json.server,
      timestamp: json.timestamp);

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
        'person': user?.toMap(),
        'custom': custom,
        'server': server,
        'framework': framework,
        'code_version': codeVersion,
        'platform_payload': platformPayload,
      }.compact();
}

extension _KeyValuePaths on JsonMap {
  JsonMap get notifier => this['notifier'];
  String get environment => this['environment'];
  Client get client => Client.fromMap(this['client']);
  JsonMap get server => this['server'];
  String get platform => this['platform'];
  String get language => this['language'];
  String get framework => this['framework'];
  String get codeVersion => this['code_version'];
  Level get level =>
      Level.values.firstWhere((level) => level.name == this['level']);
  Body get body => Body.fromMap(this['body']);
  User? get user => (this['person'] as JsonMap?).map(User.fromMap);
  JsonMap? get custom => this['custom'];
  JsonMap? get platformPayload => this['platform_payload'];
  DateTime get timestamp =>
      DateTime.fromMicrosecondsSinceEpoch(this['timestamp'], isUtc: true);
}
