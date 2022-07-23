/// Identity function a -> a
T identity<T>(T x) => x;

/// Constant function a -> (b -> a)
T Function(U Function(T)) constant<T, U>(T x) => (U Function(T) f) {
      f(x);
      return x;
    };

/// Binary function currying. Allows for partial application of binary
/// functions.
C Function(B) Function(A) curry2<A, B, C>(C Function(A, B) f) =>
    (A a) => (B b) => f(a, b);
