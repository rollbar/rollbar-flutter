import 'package:sqlite3/sqlite3.dart';

extension SingleRow on ResultSet {
  /// Returns the only single 'Row' that exists in the `ResultSet`, or `null`
  /// if there are none or more than a single row.
  Row? get singleRow {
    try {
      return single;
    } catch (_) {
      return null;
    }
  }
}
