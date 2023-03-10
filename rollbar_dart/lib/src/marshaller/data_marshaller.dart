import 'dart:io' show Platform;

import 'package:meta/meta.dart';
import 'package:rollbar_dart/rollbar_dart.dart';
import 'package:rollbar_dart/src/data/event.dart';
import 'package:rollbar_dart/src/stacktrace.dart';

/// Prepares the payload data in a Rollbar-friendly format for the [Sender].
@sealed
@immutable
@internal
class DataMarshaller implements Marshaller {
  final Config config;

  DataMarshaller(this.config);

  @override
  Data marshall({
    required final Context context,
    required final Notification event,
  }) =>
      Data(
          body: _Body.from(context, event),
          client: _Client.fromPlatform(),
          user: context.user,
          codeVersion: context.config.codeVersion,
          environment: context.config.environment,
          framework: context.config.framework,
          language: 'dart',
          level: event.level,
          notifier: {'version': Notifier.version, 'name': Notifier.name},
          platform: Platform.operatingSystem,
          server: {'root': context.config.package},
          timestamp: DateTime.now().toUtc());
}

extension _Body on Body {
  static Body from(final Context context, final Event event) => Body(
        telemetry: context.telemetry.breadcrumbs(),
        report: _Report.from(event),
      );
}

extension _Report on Report {
  static Report from(final Event event) {
    if (event is MessageEvent) {
      return Message(text: event.message);
    } else if (event is ErrorEvent) {
      return Trace(
        exception: _ExceptionInfo.from(
          error: event.error,
          description: event.description,
        ),
        frames: event.stackTrace.frames,
        rawTrace: event.stackTrace.rawTrace,
      );
    } else {
      throw ArgumentError.value(
        event,
        'event',
        "Can't derive Report from this event",
      );
    }
  }
}

extension _ExceptionInfo on ExceptionInfo {
  static ExceptionInfo from({
    required dynamic error,
    required String? description,
  }) {
    if (error is ExceptionInfo) {
      return error.copyWith(description: error.description ?? description);
    } else if (error is Object) {
      return ExceptionInfo(
          type: error.runtimeType.toString(),
          message: error.toString(),
          description: description);
    } else {
      throw ArgumentError.value(
        error,
        'error',
        "Can't derive ExceptionInfo from this error",
      );
    }
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
