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
