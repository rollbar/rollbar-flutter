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
class TelemetryEvent implements Event {
  final Breadcrumb breadcrumb;

  const TelemetryEvent(this.breadcrumb);

  @override
  String toString() => 'TelemetryEvent(breadcrumb: $breadcrumb)';
}

@sealed
class UserEvent implements Event {
  final User? user;

  const UserEvent(this.user);

  @override
  String toString() => 'UserEvent(user: $user)';
}

@sealed
class MessageEvent implements Notification, Event {
  @override
  final Level level;
  final String message;

  const MessageEvent(
    this.message, {
    this.level = Level.info,
  });

  @override
  String toString() => 'MessageEvent(level: $level, message: $message)';
}

@sealed
class ErrorEvent implements Notification, Event {
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

  @override
  String toString() => 'ErrorEvent('
      'level: $level, '
      'error: $error, '
      'description: $description, '
      'stackTrace: $stackTrace)';
}

@sealed
@internal
class ContextSnapshot implements Event {}
