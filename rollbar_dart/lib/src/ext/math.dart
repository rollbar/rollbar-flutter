import 'dart:math';

/// This extension allows Duration to be created straight from the integer.
///
/// ```dart
/// await Future.delayed(Duration(seconds: 10)); // Before
/// await Future.delayed(10.seconds); // After
/// ```
extension DurationExtension on int {
  Duration get days => Duration(days: this);
  Duration get hours => Duration(hours: this);
  Duration get minutes => Duration(minutes: this);
  Duration get seconds => Duration(seconds: this);
  Duration get milliseconds => Duration(milliseconds: this);
  Duration get microseconds => Duration(microseconds: this);
}

extension RandomExtensions on Random {
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  String nextString(int length) {
    int nextChar(_) => _chars.codeUnitAt(nextInt(_chars.length));
    return String.fromCharCodes(Iterable.generate(length, nextChar));
  }
}
