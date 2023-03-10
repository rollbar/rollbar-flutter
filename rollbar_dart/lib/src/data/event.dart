import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';
import 'package:rollbar_dart/rollbar_dart.dart';

/// A library [Event].
///
/// An [Event] is anything that triggers a side-effect within the library, be
/// it changing state (eg. context), or communicating with the Rollbar API.
///
/// Each [Event] instance carries contextual information specific to its event.
@immutable
abstract class Event {}

/// A notification event.
///
/// A notification instructs the Rollbar SDK to notify the Rollbar API of an
/// event.
abstract class Notification implements Event {
  Level get level;
}

@sealed
class TelemetryEvent with DebugStringRepresentation implements Event {
  final Breadcrumb breadcrumb;

  const TelemetryEvent(this.breadcrumb);
}

@sealed
class UserEvent with DebugStringRepresentation implements Event {
  final User? user;

  const UserEvent(this.user);
}

@sealed
class MessageEvent
    with DebugStringRepresentation
    implements Notification, Event {
  @override
  final Level level;
  final String message;

  const MessageEvent(this.message, {this.level = Level.info});
}

@sealed
class ErrorEvent with DebugStringRepresentation implements Notification, Event {
  @override
  final Level level;
  final dynamic error;
  final String? description;
  final StackTrace stackTrace;

  const ErrorEvent(
    this.error,
    this.stackTrace, {
    this.description,
    this.level = Level.error,
  });
}

@sealed
@internal
class ContextSnapshot implements Event {}
