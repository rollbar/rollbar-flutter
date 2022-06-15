import 'dart:developer' as developer;

// internal SDK logging (for the SDK use only!!!):

void info(String message, dynamic error) => _log(800, message, error);
void warn(String message, dynamic error) => _log(900, message, error);
void err(String message, dynamic error) => _log(1000, message, error);

void _log(int level, String message, dynamic error) {
  developer.log(
    message,
    level: level,
    name: 'com.rollbar.rollbar-dart',
    error: error?.toString(),
  );
}
