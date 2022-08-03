import 'package:sqlite3/sqlite3.dart' show ResultSet, Row;

extension ResultSetExtensions on ResultSet {
  /// Returns the only single 'Row' that exists in the `ResultSet`, or `null`
  /// if there are none or more than a single row.
  Row? get trySingle {
    try {
      return single;
    } catch (_) {
      return null;
    }
  }

  /// Returns the unique integer value in the results.
  ///
  /// Useful when executing `SELECT COUNT` functions.
  int get intValue => single.columnAt(0) as int;

  /// Returns the unique boolean value in the results.
  ///
  /// Useful when executing `SELECT EXISTS` functions.
  bool get boolValue => intValue != 0;
}
