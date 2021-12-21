import 'dart:developer' as developer;

/// Internal SDK logging (for the SDK use only!!!):
class Logging {
  static void info(String message, dynamic error) {
    _log(800, message, error);
  }

  static void warning(String message, dynamic error) {
    _log(900, message, error);
  }

  static void error(String message, dynamic error) {
    _log(1000, message, error);
  }

  static void _log(int level, String message, dynamic error) {
    var logName = 'com.rollbar.rollbar-dart';
    if (error != null) {
      developer.log(message,
          level: level, name: logName, error: error.toString());
    } else {
      developer.log(message, level: level, name: logName);
    }
  }
}
