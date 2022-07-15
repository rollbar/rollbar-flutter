import 'dart:core';
import 'package:meta/meta.dart';

@internal
typedef JsonMap = Map<String, dynamic>;

typedef Predicate<E> = bool Function(E);
typedef Transform<T, E> = T Function(E);

extension TryFirst<E> on Iterable<E> {
  /// Returns the first element or `null` if the list is empty.
  @internal
  E? get tryFirst => isNotEmpty ? first : null;
}

extension Predicates<E> on Iterable<E> {
  /// Checks whether all elements of this iterable satisfy [p].
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
  bool all(Predicate p) {
    for (E e in this) {
      if (!p(e)) return false;
    }

    return true;
  }
}

extension MapIf<E> on Iterable<E> {
  Iterable<E> mapIf(Predicate<E> p, Transform<E, E> f) =>
      map((e) => p(e) ? f(e) : e);

  void forEachIf(Predicate<E> p, void Function(E) f) {
    for (final e in this) {
      if (p(e)) f(e);
    }
  }
}

extension CompactList<E> on List<E?> {
  /// Returns a new non-null List by filtering out null values in the this List.
  @internal
  List<E> compact() => whereType<E>().toList();
}

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
