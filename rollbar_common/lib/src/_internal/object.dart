extension TryAs on Object? {
  /// Turns this `Object?` into an `Object`.
  T unwrap<T>() => this as T;

  /// Safely casts `this` to `T` if `this` is `T`,
  /// otherwise returns `null`.
  T? tryAs<T>() => this is T ? this as T : null;
}

// Higher-order over `Object?`

extension HigherOrderMap<T> on T? {
  /// Applies a transformation `f` to `this` if `this` is not `null`.
  U? map<U>(U Function(T) f) => this != null ? f(unwrap()) : null;

  U? flatMap<U>(U? Function(T) f) => this != null ? f(unwrap()) : null;
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
