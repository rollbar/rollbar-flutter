import 'package:meta/meta.dart';

import '../rollbar.dart';
import 'ext/collections.dart';
import 'sender/persistent_sender.dart';

/// Configuration for the [Rollbar] notifier.
@immutable
class Config {
  final String accessToken;
  final String endpoint;
  final String environment;
  final String framework;
  final String? codeVersion;
  final String package;
  final bool persistPayloads;
  final bool handleUncaughtErrors;
  final bool includePlatformLogs;

  /// If [handleUncaughtErrors] is enabled, the transformer function *must* be
  /// a static or free function, and cannot be a closure or instance function,
  /// since it will need to be passed to an error handler isolate as a message.
  final Transformer Function(Config)? transformer;

  /// If [handleUncaughtErrors] is enabled, the sender factory *must* be
  /// a static or free function, and cannot be a closure or instance function,
  /// since it will need to be passed to an error handler isolate as a message.
  final Sender Function(Config) sender;

  Config({
    required this.accessToken,
    this.endpoint = 'https://api.rollbar.com/api/1/item/',
    this.environment = 'development',
    this.framework = 'dart',
    this.codeVersion,
    required this.package,
    this.persistPayloads = false,
    this.handleUncaughtErrors = false,
    this.includePlatformLogs = false,
    this.transformer,
    this.sender = persistentSender,
  });

  factory Config.from(
    Config other, {
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
  }) {
    return Config(
      accessToken: accessToken ?? other.accessToken,
      endpoint: endpoint ?? other.endpoint,
      environment: environment ?? other.environment,
      framework: framework ?? other.framework,
      codeVersion: codeVersion ?? other.codeVersion,
      package: package ?? other.package,
      persistPayloads: persistPayloads ?? other.persistPayloads,
      handleUncaughtErrors: handleUncaughtErrors ?? other.handleUncaughtErrors,
      includePlatformLogs: includePlatformLogs ?? other.includePlatformLogs,
      transformer: transformer ?? other.transformer,
      sender: sender ?? other.sender,
    );
  }

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
      includePlatformLogs: map['includePlatformLogs'],
      transformer: map['transformer'],
      sender: map['sender']);

  /// Converts the current configuration to a [Map], so that we can share
  /// configs between isolates. Technically sending arbitrary objects through
  /// a [SendPort] is not supported. It works as long as both isolates are
  /// part of the same process, but it is not currently a documented feature,
  /// whereas sending a [Map] as the message is.
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
        'transformer': transformer,
        'sender': sender,
      };
}

// class ConfigBuilder {
//   final String accessToken;
//   String endpoint = 'https://api.rollbar.com/api/1/item/';
//   String? environment;
//   String? framework;
//   String? codeVersion;
//   String package;

//   bool persistPayloads = false;
//   bool handleUncaughtErrors = false;
//   bool includePlatformLogs = false;

//   /// If [handleUncaughtErrors] is enabled, the transformer function *must* be
//   /// a static or free function, and cannot be a closure or instance function,
//   /// since it will need to be passed to an error handler isolate as a message.
//   Transformer Function(Config)? transformer;

//   /// If [handleUncaughtErrors] is enabled, the sender factory *must* be
//   /// a static or free function, and cannot be a closure or instance function,
//   /// since it will need to be passed to an error handler isolate as a message.
//   Sender Function(Config)? sender;

//   ConfigBuilder(this.accessToken);

//   ConfigBuilder.from(Config config)
//       : accessToken = config.accessToken,
//         endpoint = config.endpoint,
//         environment = config.environment,
//         framework = config.framework,
//         codeVersion = config.codeVersion,
//         package = config.package,
//         persistPayloads = config.persistPayloads,
//         handleUncaughtErrors = config.handleUncaughtErrors,
//         includePlatformLogs = config.includePlatformLogs,
//         transformer = config.transformer,
//         sender = config.sender;

//   Config build() => Config(
//       accessToken,
//       endpoint,
//       environment,
//       framework,
//       codeVersion,
//       package,
//       persistPayloads,
//       handleUncaughtErrors,
//       includePlatformLogs,
//       transformer,
//       sender ?? persistentSender);
// }

Sender persistentSender(Config config) => PersistentSender(
    config: config,
    destination: Destination(
      endpoint: config.endpoint,
      accessToken: config.accessToken,
    ));
