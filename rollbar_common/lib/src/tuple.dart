import 'package:meta/meta.dart';

import 'zipped.dart';

@sealed
@immutable
class Tuple2<T1, T2> {
  final T1 first;
  final T2 second;

  T1 get $1 => first;
  T2 get $2 => second;

  const Tuple2(this.first, this.second);

  factory Tuple2.empty() => Tuple2(null as T1, null as T2);

  /// Create a new tuple value with the specified list [items].
  factory Tuple2.fromList(List items) {
    switch (items.length) {
      case 0:
        return Tuple2.empty();
      case 1:
        return Tuple2(items.first as T1, null as T2);
      default:
        return Tuple2(items[0] as T1, items[1] as T2);
    }
  }

  // Takes two nullables and returns a nullable of the corresponding pair.
  static Tuple2<A, B>? zip<A, B>(A? first, B? second) =>
      first != null && second != null ? Tuple2(first, second) : null;

  // Takes two iterables and returns a single iterable of corresponding pairs.
  static Iterable<Tuple2<A, B>> zipIt<A, B>(
    Iterable<A> first,
    Iterable<B> second,
  ) =>
      ZippedIterable(first, second);

  Tuple2<U, T2> mapFirst<U>(U Function(T1) f) => Tuple2(f(first), second);
  Tuple2<T1, U> mapSecond<U>(U Function(T2) f) => Tuple2(first, f(second));

  @override
  String toString() => '($first, $second)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tuple2 && other.first == first && other.second == second);

  @override
  int get hashCode => Object.hash(first, second);
}
