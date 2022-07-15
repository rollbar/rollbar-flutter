import 'dart:io' show Platform;
import 'dart:async';

import 'package:meta/meta.dart';

import '../../rollbar.dart';
import 'ext/object.dart';

@internal
typedef DataTransform = Future<Data> Function(Data);

/// A class that performs the core functions for the notifier:
/// - Prepare a payload from the provided error or message.
/// - Apply the configured transformation, if any.
/// - Send the occurrence payload to Rollbar via a [Sender].
class CoreNotifier {
  final Config config;
  final Sender _sender;
  final Transformer? _transformer;

  // notifierVersion to be updated with each new release:
  static const version = '0.3.0-beta';
  static const name = 'rollbar-dart';

  CoreNotifier({required this.config})
      : _sender = config.sender(config),
        _transformer = config.transformer?.call(config);

  Future<void> message(Level level, String message) async {
    final body = Body.from(message);
    final data = await makeData(config, level, body);
    final payload = Payload(config.accessToken, data);
    await _sender.send(payload.toMap());
  }

  Future<void> notify(
    Level level,
    dynamic error,
    StackTrace? stackTrace, [
    String? message,
  ]) async {
    final body = Body.from(message, error: error, stackTrace: stackTrace);
    final data = await makeData(config, level, body, map(error, stackTrace));
    final payload = Payload(config.accessToken, data);
    await _sender.send(payload.toMap());
  }

  @internal
  DataTransform? map(dynamic error, StackTrace? stackTrace) =>
      (_transformer?.transform).map((transform) =>
          (data) async => await transform(error, stackTrace, data));

  @internal
  Future<Data> makeData(
    Config config,
    Level level,
    Body body, [
    DataTransform? transform,
  ]) async {
    final data = Data(
        body: body,
        timestamp: DateTime.now().microsecondsSinceEpoch,
        language: 'dart',
        level: level,
        platform: Platform.operatingSystem,
        framework: config.framework,
        codeVersion: config.codeVersion,
        client: Client.fromPlatform(),
        environment: config.environment,
        notifier: {'version': CoreNotifier.version, 'name': CoreNotifier.name},
        server: {'root': config.package});

    return await transform?.call(data) ?? data;
  }
}
