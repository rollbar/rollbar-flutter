import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

import 'data/payload/reading.dart';
import 'telemetry.dart';

@sealed
@immutable
class Occurrence {
  final Level level;
  final dynamic error;
  final StackTrace? stackTrace;
  final String? message;
  final Reading? reading;
  final Telemetry? telemetry;

  const Occurrence({
    this.level = Level.info,
    this.error,
    this.stackTrace,
    this.message,
    this.reading,
    this.telemetry,
  });

  Occurrence copyWith({
    Level? level,
    dynamic error,
    StackTrace? stackTrace,
    String? message,
    Reading? reading,
    Telemetry? telemetry,
  }) =>
      Occurrence(
          level: level ?? this.level,
          error: error ?? this.error,
          stackTrace: stackTrace ?? this.stackTrace,
          message: message ?? this.message,
          reading: reading ?? this.reading,
          telemetry: telemetry ?? this.telemetry);

  @override
  String toString() => 'Event('
      'level: $level, '
      'error: $error, '
      'stackTrace: $stackTrace, '
      'message: $message, '
      'reading: $reading, '
      'telemetry: $telemetry)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Occurrence &&
          other.level == level &&
          other.error == error &&
          other.stackTrace == stackTrace &&
          other.message == message &&
          other.reading == reading &&
          other.telemetry == telemetry);

  @override
  int get hashCode => Object.hash(
        level,
        error,
        stackTrace,
        message,
        reading,
        telemetry,
      );
}
