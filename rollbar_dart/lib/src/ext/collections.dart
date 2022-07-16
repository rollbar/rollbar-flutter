import 'dart:core';
import 'package:meta/meta.dart';
import 'package:rollbar_dart/src/ext/tuple.dart';

typedef JsonMap = Map<String, dynamic>;

typedef Predicate<E> = bool Function(E);
typedef Transform<T, E> = T Function(E);

/// Tests whether the given argument [x] is `null`.
///
/// Useful as a predicate for filter-type higher-order functions.
///
/// ```dart
/// ['a', 'null', 'c', null, 'd'].any(isNull) // true
/// ```
bool isNull<T>(T? x) => x == null;

/// Tests whether the given argument [x] is not `null`.
///
/// Useful as a predicate for filter-type higher-order functions.
///
/// ```dart
/// ['a', 'null', 'c', null, 'd'].where(isNotNull) // ['a', 'c', 'd']
/// ```
bool isNotNull<T>(T? x) => x != null;

extension TryFirst<E> on Iterable<E> {
  /// Returns the first element or `null` if the list is empty.
  @internal
  E? get tryFirst => isNotEmpty ? first : null;

  /// Returns the [index]th element or `null` if out of bounds.
  E? tryElementAt(int index) {
    try {
      return elementAt(index);
    } catch (_) {
      return null;
    }
  }
}

@internal
extension Predicates<E> on Iterable<E> {
  /// Checks whether all elements of this iterable satisfy the given
  /// predicate [p].
  ///
  /// Checks every element in iteration order, and returns `true` if
  /// all of them make [p] return `true`, otherwise returns false.
  ///
  /// Example:
  /// ```dart
  /// final numbers = <int>[1, 2, 3, 5, 6, 7];
  /// var result = numbers.all((n) => n >= 5); // false;
  /// result = numbers.all((n) => n < 10); // true;
  /// ```
  @internal
  bool all(Predicate<E> p) {
    for (E e in this) {
      if (!p(e)) return false;
    }

    return true;
  }

  /// Maps over elements that satisfy the given predicate.
  Iterable<E> mapIf(Predicate<E> p, Transform<E, E> f) =>
      map((e) => p(e) ? f(e) : e);
}

@internal
extension SplitString on String {
  Tuple2<String, String> splitOnce(Pattern p) {
    final it = p.allMatches(this).iterator;
    if (it.moveNext()) {
      final m = it.current;
      return Tuple2(substring(0, m.start), substring(m.end));
    }

    return Tuple2('', '');
  }
}

@internal
extension CompactList<E> on List<E?> {
  /// Returns a new non-null List by filtering out null values in the this List.
  @internal
  List<E> compact() => whereType<E>().toList();
}

@internal
extension WhereMap<K, V> on Map<K, V> {
  /// Returns a new Map by filtering its elements using the given predicate.
  @internal
  Map<K, V> where(bool Function(K, V) p) {
    Map<K, V> map = {};

    forEach((k, v) {
      if (p(k, v)) {
        map[k] = v;
      }
    });

    return map;
  }
}

@internal
extension CompactMap<K, V> on Map<K, V?> {
  /// Returns a new non-null Map by filtering out null values in the this Map.
  @internal
  Map<K, V> compact() {
    Map<K, V> map = {};

    forEach((k, v) {
      if (v != null) {
        map[k] = v;
      }
    });

    return map;
  }
}
