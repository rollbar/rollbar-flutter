class Tuple2<T1, T2> {
  final T1 first;
  final T2 second;

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

  @override
  String toString() => '($first, $second)';

  @override
  bool operator ==(Object other) =>
      other is Tuple2 && other.first == first && other.second == second;

  @override
  int get hashCode => first.hashCode ^ second.hashCode;
}
