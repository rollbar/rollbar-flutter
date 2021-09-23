import 'package:rollbar_dart/src/http_sender.dart';

import 'transformer.dart';
import 'sender.dart';

/// Configuration for the [Rollbar] notifier.
class Config {
  final String accessToken;
  final String endpoint;
  final String environment;
  final String framework;
  final String codeVersion;
  final String package;
  final bool handleUncaughtErrors;
  final bool includePlatformLogs;
  final Transformer Function(Config) transformer;
  final Sender Function(Config) sender;

  Config._(
      this.accessToken,
      this.endpoint,
      this.environment,
      this.framework,
      this.codeVersion,
      this.package,
      this.handleUncaughtErrors,
      this.includePlatformLogs,
      this.transformer,
      this.sender);

  /// Converts the current configuration to a [Map], so that we can share configs between isolates.
  /// Technically sending arbitrary objects through a [SendPort] is not supported. It works
  /// as long as both isolates are part of the same process, but it is not currently a documented
  /// feature, whereas sending a [Map] as the message is.
  Map<String, dynamic> toMap() {
    return {
      'accessToken': accessToken,
      'endpoint': endpoint,
      'environment': environment,
      'framework': framework,
      'codeVersion': codeVersion,
      'package': package,
      'handleUncaughtErrors': handleUncaughtErrors,
      'includePlatformLogs': includePlatformLogs,
      'transformer': transformer,
      'sender': sender
    };
  }

  /// Converts the [Map] instance into a [Config] object.
  static Config fromMap(Map<String, dynamic> values) {
    return (ConfigBuilder(values['accessToken'])
          ..endpoint = values['endpoint']
          ..environment = values['environment']
          ..framework = values['framework']
          ..codeVersion = values['codeVersion']
          ..package = values['package']
          ..handleUncaughtErrors = values['handleUncaughtErrors']
          ..includePlatformLogs = values['includePlatformLogs']
          ..transformer = values['transformer']
          ..sender = values['sender'])
        .build();
  }
}

class ConfigBuilder {
  final String accessToken;
  String endpoint = 'https://api.rollbar.com/api/1/item/';
  String environment;
  String framework;
  String codeVersion;
  String package;

  bool handleUncaughtErrors = false;
  bool includePlatformLogs = false;

  /// If [handleUncaughtErrors] is enabled, the transformer function *must* be a static
  /// or free function, and cannot be a closure or instance function, since it will need
  /// to be passed to an error handler isolate as a message.
  Transformer Function(Config) transformer;

  /// If [handleUncaughtErrors] is enabled, the sender factory *must* be a static
  /// or free function, and cannot be a closure or instance function, since it will need
  /// to be passed to an error handler isolate as a message.
  Sender Function(Config) sender;

  ConfigBuilder(this.accessToken);

  ConfigBuilder.from(Config config)
      : accessToken = config.accessToken,
        endpoint = config.endpoint,
        environment = config.environment,
        framework = config.framework,
        codeVersion = config.codeVersion,
        package = config.package,
        handleUncaughtErrors = config.handleUncaughtErrors,
        includePlatformLogs = config.includePlatformLogs,
        transformer = config.transformer,
        sender = config.sender;

  Config build() {
    var sender = this.sender;
    sender ??= _httpSender;
    return Config._(
        accessToken,
        endpoint,
        environment,
        framework,
        codeVersion,
        package,
        handleUncaughtErrors,
        includePlatformLogs,
        transformer,
        sender);
  }
}

Sender _httpSender(Config config) {
  return HttpSender(config.endpoint, config.accessToken);
}
