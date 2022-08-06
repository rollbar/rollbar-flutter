import 'package:meta/meta.dart';

extension TryAs on Object? {
  /// Safely casts the value to [T] if it is [T], otherwise returns `null`.
  @useResult
  T? tryAs<T>() => this is T ? this as T : null;
}

extension HigherOrderFunctions<T> on T? {
  /// Applies a transformation [f] to the value if it is not `null`.
  @useResult
  U? map<U>(U Function(T) f) => this != null ? f(this as T) : null;

  /// Applies a transformation [f] that may return null to the value
  /// if it is not `null`.
  @useResult
  U? flatMap<U>(U? Function(T) f) => this != null ? f(this as T) : null;

  /// Maps over the value if it is not null and satisfies the given predicate.
  @useResult
  U? mapIf<U>(bool Function(T) p, U Function(T) f) =>
      this != null && p(this as T) ? f(this as T) : null;

  /// Returns the value if it's not a `null`, otherwise returns the
  /// alternative [alt].
  @useResult
  T or(T alt) => this != null ? this as T : alt;

  /// Returns the value if it's not a `null`, otherwise calls [f] and
  /// returns the result.
  ///
  /// The function [f] won't be evaluated if the value is not `null`,
  /// for example:
  /// ```dart
  /// instance.orElse(() => throw StateError('instance cannot be null'));
  /// ```
  ///
  /// If `instance` is not `null`, the throwing function is never called.
  @useResult
  T orElse(T Function() f) => this != null ? this as T : f();

  /// Calls the provided closure with a reference to the value if it is not
  /// `null` and returns the value.
  T? inspect(void Function(T) f) {
    final self = this;
    if (self != null) f(self);
    return self;
  }
}
