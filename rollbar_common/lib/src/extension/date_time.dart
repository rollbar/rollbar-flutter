import 'dart:core';

extension DateTimeComparison on Comparable<DateTime> {
  bool operator <(DateTime other) => compareTo(other) < 0;
  bool operator >(DateTime other) => compareTo(other) > 0;
  bool operator <=(DateTime other) => compareTo(other) <= 0;
  bool operator >=(DateTime other) => compareTo(other) >= 0;
}

extension DateTimeMath on DateTime {
  DateTime operator +(Duration duration) => add(duration);
  DateTime operator -(Duration duration) => subtract(duration);
}
