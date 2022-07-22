import 'package:meta/meta.dart';

import '../../rollbar.dart';
import '../ext/collection.dart';
import '../ext/environment.dart';
import '../sender/persistent_sender.dart';

/// Configuration for the [Rollbar] notifier.
@immutable
class Config {
  final String accessToken;
  final String endpoint;
  final String environment;
  final String framework;
  final String codeVersion;
  final String? package;
  final bool persistPayloads;
  final bool handleUncaughtErrors;
  final bool includePlatformLogs;

  final Transformer Function(Config)? transformer;
  final Sender Function(Config) sender;

  const Config({
    required this.accessToken,
    this.endpoint = 'https://api.rollbar.com/api/1/item/',
    this.environment = Environment.mode,
    this.framework = 'dart',
    this.codeVersion = 'main',
    this.package,
    this.persistPayloads = false,
    this.handleUncaughtErrors = true,
    this.includePlatformLogs = false,
    this.transformer,
    this.sender = PersistentSender.new,
  });

  Config copyWith({
    String? accessToken,
    String? endpoint,
    String? environment,
    String? framework,
    String? codeVersion,
    String? package,
    bool? persistPayloads,
    bool? handleUncaughtErrors,
    bool? includePlatformLogs,
    Transformer Function(Config)? transformer,
    Sender Function(Config)? sender,
  }) =>
      Config(
        accessToken: accessToken ?? this.accessToken,
        endpoint: endpoint ?? this.endpoint,
        environment: environment ?? this.environment,
        framework: framework ?? this.framework,
        codeVersion: codeVersion ?? this.codeVersion,
        package: package ?? this.package,
        persistPayloads: persistPayloads ?? this.persistPayloads,
        handleUncaughtErrors: handleUncaughtErrors ?? this.handleUncaughtErrors,
        includePlatformLogs: includePlatformLogs ?? this.includePlatformLogs,
        transformer: transformer ?? this.transformer,
        sender: sender ?? this.sender,
      );

  /// Converts the [Map] instance into a [Config] object.
  factory Config.fromMap(JsonMap map) => Config(
      accessToken: map['accessToken'],
      endpoint: map['endpoint'],
      environment: map['environment'],
      framework: map['framework'],
      codeVersion: map['codeVersion'],
      package: map['package'],
      persistPayloads: map['persistPayloads'],
      handleUncaughtErrors: map['handleUncaughtErrors'],
      includePlatformLogs: map['includePlatformLogs']);

  JsonMap toMap() => {
        'accessToken': accessToken,
        'endpoint': endpoint,
        'environment': environment,
        'framework': framework,
        'codeVersion': codeVersion,
        'package': package,
        'persistPayloads': persistPayloads,
        'handleUncaughtErrors': handleUncaughtErrors,
        'includePlatformLogs': includePlatformLogs,
      };
}
