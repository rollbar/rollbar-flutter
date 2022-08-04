import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

import 'data/payload/breadcrumb.dart';
import 'telemetry.dart';

@sealed
@immutable
class Event {
  final Level level;
  final dynamic error;
  final StackTrace? stackTrace;
  final String? message;
  final Breadcrumb? breadcrumb;
  final Telemetry? telemetry;

  const Event({
    this.level = Level.info,
    this.error,
    this.stackTrace,
    this.message,
    this.breadcrumb,
    this.telemetry,
  });

  Event copyWith({
    Level? level,
    dynamic error,
    StackTrace? stackTrace,
    String? message,
    Breadcrumb? breadcrumb,
    Telemetry? telemetry,
  }) =>
      Event(
          level: level ?? this.level,
          error: error ?? this.error,
          stackTrace: stackTrace ?? this.stackTrace,
          message: message ?? this.message,
          breadcrumb: breadcrumb ?? this.breadcrumb,
          telemetry: telemetry ?? this.telemetry);

  @override
  String toString() => 'Event('
      'level: $level, '
      'error: $error, '
      'stackTrace: $stackTrace, '
      'message: $message, '
      'breadcrumb: $breadcrumb, '
      'telemetry: $telemetry)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.level == level &&
          other.error == error &&
          other.stackTrace == stackTrace &&
          other.message == message &&
          other.breadcrumb == breadcrumb &&
          other.telemetry == telemetry);

  @override
  int get hashCode => Object.hash(
        level,
        error,
        stackTrace,
        message,
        breadcrumb,
        telemetry,
      );
}
