import 'dart:collection';

import 'package:meta/meta.dart';
import 'tuple.dart';

extension ZippedIterableExtension<A> on Iterable<A> {
  ZippedIterable<A, B> zip<B>(Iterable<B> other) => ZippedIterable(this, other);
}

@sealed
@immutable
class ZippedIterable<A, B>
    with IterableMixin<Tuple2<A, B>>
    implements Iterable<Tuple2<A, B>> {
  final Iterable<A> _ita;
  final Iterable<B> _itb;

  const ZippedIterable(this._ita, this._itb);

  @override
  Iterator<Tuple2<A, B>> get iterator =>
      ZippedIterator(_ita.iterator, _itb.iterator);
}

@sealed
class ZippedIterator<E1, E2> implements Iterator<Tuple2<E1, E2>> {
  final Iterator<E1> _ita;
  final Iterator<E2> _itb;
  Tuple2<E1, E2>? _current;

  ZippedIterator(this._ita, this._itb);

  @override
  Tuple2<E1, E2> get current => _current as Tuple2<E1, E2>;

  @override
  bool moveNext() {
    final moved = _ita.moveNext() && _itb.moveNext();
    _current = moved ? Tuple2(_ita.current, _itb.current) : null;
    return moved;
  }
}
