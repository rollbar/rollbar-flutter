import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

import '../telemetry.dart';

@sealed
@immutable
class Event {
  final Level level;
  final dynamic error;
  final StackTrace? stackTrace;
  final String? message;
  final Telemetry telemetry;

  const Event({
    this.level = Level.info,
    this.error,
    this.stackTrace,
    this.message,
    required this.telemetry,
  });

  @override
  String toString() => 'Event('
      'level: $level, '
      'error: $error, '
      'stackTrace: $stackTrace, '
      'message: $message, '
      'telemetry: $telemetry)';
}
