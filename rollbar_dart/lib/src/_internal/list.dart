import 'dart:core';

extension TryFirst<E> on List<E> {
  /// Returns the first element or `null` if the list is empty.
  E? get tryFirst => isNotEmpty ? first : null;
}
