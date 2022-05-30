import 'dart:developer' as developer;

/// Internal SDK logging (for the SDK use only!!!):
class Logging {
  static void info(String message, dynamic error) => _log(800, message, error);
  static void warn(String message, dynamic error) => _log(900, message, error);
  static void err(String message, dynamic error) => _log(1000, message, error);

  static void _log(int level, String message, dynamic error) {
    developer.log(
      message,
      level: level,
      name: 'com.rollbar.rollbar-dart',
      error: error?.toString(),
    );
  }
}
