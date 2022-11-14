import 'dart:async';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:rollbar_common/rollbar_common.dart';

import '../rollbar.dart';
import 'notifier/isolated_notifier.dart';
import 'wrangler/data_wrangler.dart';
import 'transformer/noop_transformer.dart';
import 'sender/persistent_http_sender.dart';

/// The class of types that are [Configurable] through a [Config] instance.
abstract class Configurable {
  Config get config;
}

/// Configuration for the [Rollbar] notifier.
@sealed
@immutable
class Config implements Serializable {
  final String accessToken;
  final String endpoint;
  final String environment;
  final String framework;
  final String codeVersion;
  final String? package;
  final String persistencePath;
  final Duration persistenceLifetime;
  final bool handleUncaughtErrors;
  final bool includePlatformLogs;

  final FutureOr<Notifier> Function(Config) notifier;
  final Wrangler Function(Config) wrangler;
  final Transformer Function(Config) transformer;
  final Sender Function(Config) sender;
  final http.Client Function() httpClient;

  const Config({
    required this.accessToken,
    this.endpoint = 'https://api.rollbar.com/api/1/item/',
    this.environment = Environment.mode,
    this.framework = 'dart',
    this.codeVersion = 'main',
    this.package,
    this.persistencePath = './',
    this.persistenceLifetime = const Duration(days: 1),
    this.handleUncaughtErrors = true,
    this.includePlatformLogs = false,
    this.notifier = IsolatedNotifier.spawn,
    this.wrangler = DataWrangler.new,
    this.transformer = NoopTransformer.new,
    this.sender = PersistentHttpSender.new,
    this.httpClient = http.Client.new,
  });

  Config copyWith({
    String? accessToken,
    String? endpoint,
    String? environment,
    String? framework,
    String? codeVersion,
    String? package,
    String? persistencePath,
    Duration? persistenceLifetime,
    bool? handleUncaughtErrors,
    bool? includePlatformLogs,
    FutureOr<Notifier> Function(Config)? notifier,
    Wrangler Function(Config)? wrangler,
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
        persistencePath: persistencePath ?? this.persistencePath,
        persistenceLifetime: persistenceLifetime ?? this.persistenceLifetime,
        handleUncaughtErrors: handleUncaughtErrors ?? this.handleUncaughtErrors,
        includePlatformLogs: includePlatformLogs ?? this.includePlatformLogs,
        notifier: notifier ?? this.notifier,
        wrangler: wrangler ?? this.wrangler,
        transformer: transformer ?? this.transformer,
        sender: sender ?? this.sender,
      );

  @override
  factory Config.fromMap(JsonMap map) => Config(
      accessToken: map['accessToken'],
      endpoint: map['endpoint'],
      environment: map['environment'],
      framework: map['framework'],
      codeVersion: map['codeVersion'],
      package: map['package'],
      persistencePath: map['persistencePath'],
      persistenceLifetime: Duration(seconds: map['persistenceLifetime']),
      handleUncaughtErrors: map['handleUncaughtErrors'],
      includePlatformLogs: map['includePlatformLogs']);

  @override
  JsonMap toMap() => {
        'accessToken': accessToken,
        'endpoint': endpoint,
        'environment': environment,
        'framework': framework,
        'codeVersion': codeVersion,
        'package': package,
        'persistencePath': persistencePath,
        'persistenceLifetime': persistenceLifetime.inSeconds,
        'handleUncaughtErrors': handleUncaughtErrors,
        'includePlatformLogs': includePlatformLogs,
      };
}
