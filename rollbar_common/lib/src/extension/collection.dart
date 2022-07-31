import 'function.dart';

typedef JsonMap = Map<String, dynamic>;

typedef Predicate<E> = bool Function(E);
typedef Transform<T, E> = T Function(E);

/// Tests whether the given argument [x] is `null`.
///
/// Useful as a predicate for filter-type higher-order functions.
///
/// ```dart
/// ['a', null, 'c', null, 'd'].any(isNull) // true
/// ```
bool isNull<T>(T? x) => x == null;

/// Tests whether the given argument [x] is not `null`.
///
/// Useful as a predicate for filter-type higher-order functions.
///
/// ```dart
/// ['a', null, 'c', null, 'd'].where(isNotNull) // ['a', 'c', 'd']
/// ```
bool isNotNull<T>(T? x) => x != null;

/// Tests whether the given boolean argument [x] is true.
///
/// Useful as a predicate for filter-type higher-order functions.
///
/// ```dart
/// [true, true, true, false, true].all(isTrue) // false
/// ```
const isTrue = idf<bool>;
// the identity function on bool forms its predicate.
// id := λx.x where x: bool ≡ bool isTrue(bool x) => x;

/// Tests whether the given boolean argument [x] is false.
///
/// Useful as a predicate for filter-type higher-order functions.
///
/// ```dart
/// [true, true, true, false, true].any(isFalse) // true
/// ```
bool isFalse(bool x) => !isTrue(x);

/// Inverses a predicate boolean evaluation.
///
/// Useful as a predicate adjunct for filter-type higher-order functions.
///
/// ```dart
/// final xs = [1, 2, 3, 4];
/// final ys = [2, 4];
/// final odds = xs.where(not(ys.contains)); // [1, 3]
/// ```
bool Function(T) not<T>(bool Function(T) p) => (x) => !p(x);

extension IterableExtensions<E> on Iterable<E> {
  /// Returns the first element or `null` if the list is empty.
  E? get tryFirst => isNotEmpty ? first : null;

  /// Returns the last element or `null` if the list is empty.
  E? get tryLast => isNotEmpty ? last : null;

  /// Returns the [i]th element or `null` if out of bounds.
  E? tryElementAt(int i) => i >= 0 && i < length ? elementAt(i) : null;

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
  bool all(Predicate<E> p) {
    for (final e in this) {
      if (!p(e)) return false;
    }

    return true;
  }

  /// Maps over elements that satisfy the given predicate.
  Iterable<E> mapWhere(Predicate<E> p, Transform<E, E> f) sync* {
    for (final e in this) {
      if (p(e)) yield f(e);
    }
  }

  Iterable<T> compactMap<T>(T? Function(E) f) sync* {
    for (final e in this) {
      final _e = f(e);
      if (_e != null) yield _e;
    }
  }
}

extension CompactList<E> on Iterable<E?> {
  /// Returns a new non-null List by filtering out null values in the this List.
  Iterable<E> compact() => whereType<E>();
}

extension Ranges on int {
  /// Creates an iterable range.
  ///
  /// Both ends of the range are _inclusive_.
  ///
  /// ```dart
  /// for (var i in 1.to(5)) {
  ///   print(i); // prints 1, 2, 3, 4, 5
  /// }
  /// ```
  Iterable<int> to(int length) sync* {
    for (var i = 0; i <= length; ++i) {
      yield i;
    }
  }
}

extension MapExtensions<K, V> on Map<K, V> {
  /// Returns an list of values for the given list of keys.
  ///
  /// The returned list respect the ordering of the keys.
  Iterable<V> valuesForKeys(Iterable<K> keys) =>
      keys.compactMap((key) => this[key]);

  /// Returns a new Map by filtering its elements using the given predicate.
  Map<K, V> where(bool Function(K, V) p) {
    Map<K, V> map = {};

    forEach((k, v) {
      if (p(k, v)) map[k] = v;
    });

    return map;
  }

  /// Returns a new non-null Map by filtering out null values in the this Map.
  Map<K, V> compact() {
    Map<K, V> map = {};

    forEach((k, v) {
      if (v != null) map[k] = v;
    });

    return map;
  }

  /// Reduces the [Map] to a single key/value pair [MapEntry] by iteratively
  /// combining [combine] each [entry] of the [Map] into an [accumulator].
  ///
  /// The [Map] must have at least one key/value pair. If it has only one pair,
  /// that pair is returned.
  ///
  /// Otherwise this method starts with the first pair from the [Map] iterator,
  /// and then combines it with the remaining pairs in iteration order.
  MapEntry<K, V> reduce(
    MapEntry<K, V> Function(MapEntry<K, V> accumulator, MapEntry<K, V> entry)
        combine,
  ) {
    Iterator<MapEntry<K, V>> iterator = entries.iterator;
    if (!iterator.moveNext()) throw ArgumentError('$this cannot be empty.');

    var entry = iterator.current;
    while (iterator.moveNext()) {
      entry = combine(entry, iterator.current);
    }

    return entry;
  }

  /// Reduces the [Map] to a single _value_ by iteratively combining [combine]
  /// each key/value pair [entry] in the [Map] with an existing value
  /// [initialValue].
  ///
  /// Uses [initialValue] as the initial value,
  /// then iterates through the key/value pairs and updates the value with
  /// the result of the [combine] function.
  T fold<T>(
    T initialValue,
    T Function(T previousValue, MapEntry<K, V> element) combine,
  ) {
    var result = initialValue;
    forEach((k, v) => result = combine(result, MapEntry(k, v)));
    return result;
  }
}
