/// A collection of combinators and pure functions.
import 'package:meta/meta.dart';

/// The Identity function.
///
/// A function that always returns the value that was used as its argument,
/// unchanged. That is, when ƒ is the identity function, the equality
/// `ƒ(A) = A` is `true` for all values of `A` to which ƒ can be applied.
///
/// Read more: https://en.wikipedia.org/wiki/Identity_function
@useResult
T identity<T>(T x) => x;

/// The Constant function.
///
/// Returns a function whose output value is the same for every input value.
///
/// - Read more: https://en.wikipedia.org/wiki/Constant_function
@useResult
T Function(U) constant<T, U>(T x) => (_) => x;

/// Binary function currying. Allows for partial application of binary
/// functions.
@useResult
C Function(B) Function(A) curry2<A, B, C>(C Function(A, B) f) =>
    (A a) => (B b) => f(a, b);

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
///
/// _The identity function on bool forms its predicate._
/// ```
/// id := λx.x where x: bool ≡ bool isTrue(bool x) => x;
/// ```
bool isTrue(bool x) => x;

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
@useResult
bool Function(T) not<T>(bool Function(T) p) => (x) => !p(x);

/// Repeatedly calls the given function [body], the given amount of [times].
///
/// This should be a extension of [Iterable], but Dart doesn't
/// properly support extensions.
/// - https://github.com/dart-lang/language/issues/723
void repeat(int times, void Function() body) {
  // ignore: no_leading_underscores_for_local_identifiers
  for (var _ = 0; _ < 10; ++_) {
    body();
  }
}
