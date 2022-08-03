import 'dart:io' show Platform;

import 'package:meta/meta.dart';

import '../stacktrace.dart';
import '../data/payload/body.dart';
import '../data/payload/client.dart';
import '../data/payload/data.dart';
import '../data/payload/exception_info.dart';
import '../data/payload/payload.dart';
import '../occurrence.dart';
import '../config.dart';
import '../transformer/transformer.dart';
import '../notifier/notifier.dart';
import 'wrangler.dart';

/// Prepares the payload data in a Rollbar-friendly format for the [Sender].
@sealed
@immutable
@internal
class DataWrangler implements Wrangler {
  @override
  final Transformer transformer;
  final Config config;

  DataWrangler(this.config) : transformer = config.transformer(config);

  @override
  Future<Payload> payload({required Occurrence event}) async {
    final data = await _Data.from(event: event, config: config);
    final transformedData = await transformer.transform(data, event: event);
    return Payload(data: transformedData);
  }
}

extension _Data on Data {
  static Future<Data> from({
    required Occurrence event,
    required Config config,
  }) async =>
      Data(
          body: _Body.from(event: event),
          client: _Client.fromPlatform(),
          codeVersion: config.codeVersion,
          environment: config.environment,
          framework: config.framework,
          language: 'dart',
          level: event.level,
          notifier: {'version': Notifier.version, 'name': Notifier.name},
          platform: Platform.operatingSystem,
          server: {'root': config.package},
          timestamp: DateTime.now().toUtc());
}

extension _Body on Body {
  static Body from({required Occurrence event}) {
    final error = event.error, message = event.message;

    if (error != null) {
      return Body(
        telemetry: event.telemetry!.snapshot(), // [todo] this is awful
        report: Trace(
            exception: _ExceptionInfo.from(error: error, description: message),
            frames: event.stackTrace?.frames ?? [],
            rawTrace: event.stackTrace?.rawTrace),
      );
    }

    if (message != null) {
      return Body(
        telemetry: event.telemetry!.snapshot(), // [todo] this is awful
        report: Message(text: message),
      );
    }

    throw ArgumentError.value(
        event, 'An Event must have either an error or a message.', 'event');
  }
}

extension _ExceptionInfo on ExceptionInfo {
  static ExceptionInfo from({
    required dynamic error,
    required String? description,
  }) {
    if (error is ExceptionInfo) {
      return error.copyWith(description: error.description ?? description);
    }

    return ExceptionInfo(
        type: error.runtimeType.toString(),
        message: error.toString(),
        description: description);
  }
}

extension _Client on Client {
  static Client fromPlatform() => Client(
      locale: Platform.localeName,
      hostname: Platform.localHostname,
      os: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
      dartVersion: Platform.version,
      numberOfProcessors: Platform.numberOfProcessors);
}
