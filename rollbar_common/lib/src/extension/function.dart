/// Identity function a -> a
T identity<T>(T x) => x;

/// Constant function a -> (b -> a)
///
/// Returns a constant function, which always returns the same value no matter
/// what argument it is given.
T Function(U) constant<T, U>(T x) => (_) => x;

/// Binary function currying. Allows for partial application of binary
/// functions.
C Function(B) Function(A) curry2<A, B, C>(C Function(A, B) f) =>
    (A a) => (B b) => f(a, b);
