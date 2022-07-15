/// Identity function a -> a
T id<T>(T x) => x;

/// Constant function a -> (b -> a)
T Function(U Function(T)) constant<T, U>(T x) => (U Function(T) f) {
      f(x);
      return x;
    };

extension TryAs on Object? {
  /// Turns this `Object?` into an `Object`.
  T unwrap<T>() => this as T;

  /// Safely casts `this` to `T` if `this` is `T`,
  /// otherwise returns `null`.
  T? tryAs<T>() => this is T ? this as T : null;
}

// Higher-order functions over `T?`

extension HigherOrderMap<T> on T? {
  /// Applies a transformation `f` to `this` if `this` is not `null`.
  U? map<U>(U Function(T) f) => this != null ? f(this as T) : null;

  T or(T alt) => this == null ? alt : this as T;

  T orElse(T Function() f) => this == null ? f() : this as T;

  T? inspect(void Function(T) f) =>
      this != null ? constant(this as T)(f) : null;
}

extension HigherOrderWhere<T> on T {
  /// Returns `this` if the following conditions are met:
  ///
  /// * `this` is not `null`
  /// * the given predicate over `this` returns `true`
  ///
  /// Otherwise returns `null`.
  T? where(bool Function(T) f) => map(f) == true ? this : null;
}
