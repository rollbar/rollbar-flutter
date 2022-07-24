import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:sqlite3/sqlite3.dart';

import 'extension/object.dart';
import 'extension/collection.dart';
import 'extension/string.dart';
import 'extension/database.dart';
import 'identifiable.dart';
import 'serializable.dart';
import 'persistable.dart';

/// TableSet
///
/// List of limitations in the generics implementation of the Dart type system
/// that complicate this implementation:
/// - https://github.com/dart-lang/language/issues/356
/// - https://github.com/dart-lang/language/issues/1152
/// - https://github.com/dart-lang/language/issues/359
@sealed
@immutable
class TableSet<E extends Persistable<UUID>> with SetMixin<E> implements Set<E> {
  final Database database;

  TableSet({bool isPersistent = false})
      : database =
            isPersistent ? sqlite3.open('rollbar.db') : sqlite3.openInMemory() {
    final typeDeclarations = _keyTypes.fold('', (String acc, kv) {
      return '$acc${kv.key} ${kv.value.sqlTypeDeclaration}, ';
    }).replaceLast(', ', '');

    database.execute('CREATE TABLE IF NOT EXISTS $_table ($typeDeclarations)');
  }

  @override
  Iterator<E> get iterator =>
      database.select('SELECT * FROM $_table').map(_deserialize).iterator;

  @override
  int get length => database.select('SELECT COUNT(*) FROM $_table').intValue;

  @override
  bool get isEmpty => length == 0;

  E? record({required UUID id}) => database
      .select('SELECT ${_keyTypes.keys.join(', ')} FROM $_table WHERE id = ?',
          [id.toBytes()])
      .trySingle
      .map(_deserialize);

  @override
  E? lookup(Object? element) => element is E ? record(id: element.id) : null;

  @override
  bool contains(Object? element) {
    if (element is! E) return false;
    final result = database.select(
        'SELECT EXISTS(SELECT 1 FROM $_table WHERE id = ?)',
        [element.id.toBytes()]);
    return result.boolValue;
  }

  @override
  bool add(Object? value) {
    if (value is! E || contains(value)) return false;
    database.execute(
        'INSERT INTO $_table (${_keyTypes.keys.join(', ')}) '
        'VALUES (${_keyTypes.keys.map((_) => '?').join(', ')})',
        value.toMap().values.toList());
    return true;
  }

  /// Updates [element] on the Set.
  ///
  /// Returns `true` if [element] was updated. If the `element` isn't in the
  /// set, returns `false` and the set is not changed.
  bool update(E element) => remove(element) ? add(element) : false;

  @override
  bool remove(Object? value) {
    if (value is! E || !contains(value)) return false;
    database.execute('DELETE FROM $_table WHERE id = ?', [value.id.toBytes()]);
    return true;
  }

  @override
  Set<E> toSet() =>
      database.select('SELECT * FROM $_table').map(_deserialize).toSet();

  /// Creates a **new** [Database] which contains all the records of this set
  /// and [other].
  ///
  /// That is, the returned [Database] contains all the records of this
  /// [Database] and all the elements of [other] that are not in this database.
  @override
  TableSet<E> union(Set<E> other) => TableSet()..addAll({...this, ...other});

  /// Creates a **new** [Database] which is the intersection between this
  /// [Database] and [other].
  ///
  /// That is, the returned [Database] contains all the records of this
  /// [Database] that are _also_ elements of [other] according to
  /// `other.contains`.
  @override
  TableSet<E> intersection(Set<Object?> other) {
    final result = TableSet<E>()..addAll(this);
    result.where(not(other.contains)).forEach(result.remove);
    return result;
  }

  /// Creates a **new** [Database] with the records of this [Database] that
  /// are not in [other].
  ///
  /// That is, the returned [Database] contains all the records of this
  /// [Database] that are not elements of [other] according to
  /// `other.contains`.
  @override
  TableSet<E> difference(Set<Object?> other) {
    final result = TableSet<E>()..addAll(this);
    result.where(other.contains).forEach(result.remove);
    return result;
  }

  String get _table => E.runtimeType.toString().toSnakeCase();
  Map<String, Datatype> get _keyTypes => Persistable.of<E>().persistingKeyTypes;
  E _deserialize(JsonMap map) => Serializable.of<E>().fromMap(map) as E;
}
