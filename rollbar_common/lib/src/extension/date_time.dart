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

extension DateTimeComparison on DateTime {
  bool operator <(DateTime other) => isBefore(other);
  bool operator >(DateTime other) => isAfter(other);
  bool operator <=(DateTime other) => compareTo(other) <= 0;
  bool operator >=(DateTime other) => compareTo(other) >= 0;
}

extension DateTimeMath on DateTime {
  DateTime operator +(Duration duration) => add(duration);
  DateTime operator -(Duration duration) => subtract(duration);
}
