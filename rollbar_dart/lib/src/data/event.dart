import 'package:meta/meta.dart';
import 'payload/data.dart' show Level;

@sealed
@immutable
class Event {
  final Level level;
  final dynamic error;
  final StackTrace? stackTrace;
  final String? message;
  //final Telemetry? telemetry;

  const Event({
    this.level = Level.info,
    this.error,
    this.stackTrace,
    this.message,
  });
}
