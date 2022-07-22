import 'function.dart';

extension TryAs on Object? {
  /// Safely casts `this` to `T` if `this` is `T`,
  /// otherwise returns `null`.
  T? tryAs<T>() => this is T ? this as T : null;
}

// Higher-order functions over `T?`

extension HigherOrderMap<T> on T? {
  /// Applies a transformation `f` to `this` if `this` is not `null`.
  U? map<U>(U Function(T) f) => this != null ? f(this as T) : null;

  U? flatMap<U>(U? Function(T) f) => this != null ? f(this as T) : null;

  T or(T alt) => this == null ? alt : this as T;

  T orElse(T Function() f) => this == null ? f() : this as T;

  T? inspect(void Function(T) f) =>
      this != null ? constant(this as T)(f) : null;

  /// Maps over elements that satisfy the given predicate.
  U? mapIf<U>(bool Function(T) p, U Function(T) f) =>
      this != null && p(this as T) ? f(this as T) : null;
}
