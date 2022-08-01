import 'package:meta/meta.dart';
import 'package:collection/collection.dart';
import 'package:rollbar_common/rollbar_common.dart';

import 'payload/reading.dart';

@sealed
@immutable
class Event implements Equatable {
  final Level level;
  final dynamic error;
  final StackTrace? stackTrace;
  final String? message;
  final Iterable<Reading> telemetry;

  const Event({
    this.level = Level.info,
    this.error,
    this.stackTrace,
    this.message,
    this.telemetry = const [],
  });

  @override
  String toString() => 'Event('
      'level: $level, '
      'error: $error, '
      'stackTrace: $stackTrace, '
      'message: $message, '
      'telemetry: $telemetry)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          IterableEquality<Reading>().equals(other.telemetry, telemetry) &&
          other.level == level &&
          other.error == error &&
          other.stackTrace == stackTrace &&
          other.message == message);

  @override
  int get hashCode => Object.hash(
        IterableEquality<Reading>().hash(telemetry),
        level,
        error,
        stackTrace,
        message,
      );
}
