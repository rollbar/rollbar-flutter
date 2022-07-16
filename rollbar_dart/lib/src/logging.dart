import 'dart:developer' as developer;
import 'package:logging/logging.dart' show Level;
import 'package:meta/meta.dart';

@internal
void log(String message, [dynamic error, StackTrace? stackTrace]) =>
    _log(Level.INFO, message, error, stackTrace);

@internal
void warn(String message, [dynamic error, StackTrace? stackTrace]) =>
    _log(Level.WARNING, message, error, stackTrace);

@internal
void err(String message, dynamic error, [StackTrace? stackTrace]) =>
    _log(Level.SEVERE, message, error, stackTrace);

void _log(Level level, String message, dynamic error, StackTrace? stackTrace) =>
    developer.log(
      message,
      level: level.value,
      name: 'com.rollbar.rollbar-dart',
      error: error,
      stackTrace: stackTrace,
    );
