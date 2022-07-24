import 'object.dart';
import 'collection.dart';
import '../tuple.dart';

extension StringExtensions on String {
  /// The first character in this [String].
  ///
  /// The [String] **must not** be empty when accessing its first character.
  String get first => this[0];

  /// The first character in this [String] or `null` if this [String]
  /// is empty.
  String? get tryFirst => isNotEmpty ? first : null;

  /// Splits the string on the first occurrence of the specified delimiter
  /// and returns prefix before delimiter and suffix after delimiter.
  Tuple2<String, String> splitOnce(Pattern p) {
    final it = p.allMatches(this).iterator;
    if (it.moveNext()) {
      final match = it.current;
      return Tuple2(substring(0, match.start), substring(match.end));
    }

    return Tuple2('', '');
  }

  /// Creates a new string with the last occurrence of [from] replaced by [to].
  ///
  /// Finds the last match of [from] in this string and creates a new string
  /// where that match is replaced with the [to] string.
  ///
  /// Example:
  /// ```dart
  /// '0.0001'.replaceLast(RegExp(r'0'), ''); // '0.001'
  /// '0.0001'.replaceLast(RegExp(r'0'), '1'); // '0.0011'
  /// ```
  String replaceLast(Pattern from, String to) => from
      .allMatches(this)
      .tryLast
      .map((match) => replaceRange(match.start, match.end, to))
      .or(this);

  /// The string trimmed from both sides by the given [length].
  ///
  /// ```dart
  /// final trimmed = '[Dee, is, a, bird]'.trimLength(1);
  /// print(trimmed); // 'Dee, is, a, bird'
  /// ```
  String trimLength(int length) => substring(length, this.length - length);

  /// The string trimmed from the left side by the given [length].
  String trimLeftLength(int length) => substring(length);

  /// The string trimmed from the right side by the given [length].
  String trimRightLength(int length) => substring(0, this.length - length);

  /// Returns a new [String] by transforming the first character of `this`
  /// [String] to uppercase and all other characters to lowercase.
  String capitalize() => //
      length < 2
          ? toUpperCase()
          : first.toUpperCase() + substring(1).toLowerCase();

  /// Returns a new [String] by turning `CamelCase` into `snake_case`.
  String toSnakeCase() => [
        RegExp(r'(.)([A-Z][a-z]+)'),
        RegExp(r'()__([A-Z])'),
        RegExp(r'([a-z0-9])([A-Z])'),
      ].fold(this, (String r, re) {
        return r.replaceAllMapped(re, (match) => '${match[1]}_${match[2]}');
      }).toLowerCase();

  /// Returns a new [String] by turning `snake_case` into `CamelCase`.
  String toCamelCase() => split('_').map((word) => word.capitalize()).join();
}
