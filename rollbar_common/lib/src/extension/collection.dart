typedef Predicate<E> = bool Function(E);
typedef KeyValuePredicate<K, V> = bool Function(K, V);
typedef Transform<T, E> = T Function(E);

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
      final te = f(e);
      if (te != null) yield te;
    }
  }
}

extension CompactIterable<E> on Iterable<E?> {
  /// Returns a new non-null List by filtering out null values in the this List.
  Iterable<E> compact() => whereType<E>();
}

extension CompactMap<K, V> on Map<K, V?> {
  /// Returns a new non-null Map by filtering out null values in the this Map.
  Map<K, V> compact() {
    Map<K, V> map = {};

    for (final entry in entries) {
      final value = entry.value;
      if (value != null) {
        map[entry.key] = value;
      }
    }

    return map;
  }
}

extension MapExtensions<K, V> on Map<K, V> {
  /// The value for the given [key], or `null` if [key] is not in the map.
  ///
  /// A functional version of `operator []` akin to [Iterable.elementAt].
  ///
  /// Some maps allow `null` as a value.
  /// For those maps, a lookup using this operator cannot distinguish between a
  /// key not being in the map, and the key being there with a `null` value.
  /// Methods like [containsKey] or [putIfAbsent] can be used if the distinction
  /// is important.
  V? valueFor(K key) => this[key];

  /// Returns an list of values for the given list of keys.
  ///
  /// The returned list respect the ordering of the keys.
  Iterable<V> valuesForKeys(Iterable<K> keys) => keys.compactMap(valueFor);

  /// Returns a new Map by filtering its entries using the given predicate.
  Map<K, V> where(KeyValuePredicate<K, V> p) {
    Map<K, V> map = {};

    forEach((k, v) {
      if (p(k, v)) map[k] = v;
    });

    return map;
  }

  /// Returns a new Map by filtering its keys using the given predicate.
  Map<K, V> whereKey(Predicate<K> p) {
    Map<K, V> map = {};

    forEach((k, v) {
      if (p(k)) map[k] = v;
    });

    return map;
  }

  /// Returns a new Map by filtering its values using the given predicate.
  Map<K, V> whereValue(Predicate<V> p) {
    Map<K, V> map = {};

    forEach((k, v) {
      if (p(v)) map[k] = v;
    });

    return map;
  }

  bool any(KeyValuePredicate<K, V> p) {
    final it = entries.iterator;
    while (it.moveNext()) {
      if (p(it.current.key, it.current.value)) {
        return true;
      }
    }

    return false;
  }

  bool anyKey(Predicate<K> p) {
    final it = entries.iterator;
    while (it.moveNext()) {
      if (p(it.current.key)) {
        return true;
      }
    }

    return false;
  }

  bool anyValue(Predicate<V> p) {
    final it = entries.iterator;
    while (it.moveNext()) {
      if (p(it.current.value)) {
        return true;
      }
    }

    return false;
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
