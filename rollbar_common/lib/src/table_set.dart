import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:sqlite3/sqlite3.dart';

import 'extension/function.dart';
import 'extension/object.dart';
import 'extension/collection.dart';
import 'extension/mirror.dart';
import 'extension/string.dart';
import 'extension/database.dart';
import 'identifiable.dart';
import 'serializable.dart';
import 'persistable.dart';

/// A collection of [Persistable] objects that leverages the `sqlite3` library
/// in which each record can occur only once.
///
/// The [Database] has two modes, persistent and in-memory.
///
/// A persistent [Database] is a _shared_ database that will store all its
/// records on the _same_ [Database] file.
///
/// An in-memory [Database] works on its own independent [Database] but it
/// won't persist multiple library runs.
///
/// Access, store or remove [Persistable] objects as if this were any given
/// [Set], all common [Set] rules apply.
///
/// List of limitations in the generics implementation of the Dart type system
/// that complicate this implementation:
/// - https://github.com/dart-lang/language/issues/349
/// - https://github.com/dart-lang/language/issues/356
/// - https://github.com/dart-lang/language/issues/1152
/// - https://github.com/dart-lang/language/issues/359
@sealed
@immutable
class TableSet<E extends Persistable<UUID>> with SetMixin<E> implements Set<E> {
  final Database database;

  TableSet({Database? database})
      : database = database ?? sqlite3.openInMemory() {
    final typeDeclarations = keyTypes.fold('', (String acc, kv) {
      return '$acc${kv.key} ${kv.value.sqlTypeDeclaration}, ';
    }).replaceLast(', ', '');

    this.database.execute(
          'CREATE TABLE IF NOT EXISTS $tableName ($typeDeclarations)',
        );
  }

  /// The name of the table.
  ///
  /// This is the name of [E] in `snake_case`.
  String get tableName => (E).toString().toSnakeCase();

  @override
  Iterator<E> get iterator =>
      database.select('SELECT * FROM $tableName').map(deserialize).iterator;

  /// Returns the number of rows in the table.
  @override
  int get length => database.select('SELECT COUNT(*) FROM $tableName').intValue;

  /// Whether this table has no rows.
  @override
  bool get isEmpty => length == 0;

  E? record({required UUID id}) => database
      .select('SELECT ${keys.join(', ')} FROM $tableName WHERE id = ?',
          [id.toBytes()])
      .trySingle
      .map(deserialize);

  @override
  E? lookup(Object? element) => element is E ? record(id: element.id) : null;

  /// Returns an iterable with this table's rows in this table by the given key
  /// column [by].
  Iterable<E> sorted({required Symbol by, bool descending = false}) {
    final symbol = by.name.split('.');
    final type = symbol.first, key = symbol.last;
    final ordering = descending ? 'DESC' : 'ASC';

    if (type != (E).toString()) {
      throw ArgumentError.value('#${by.name}', 'by',
          'Type mismatch, found $type, expected ${(E).toString()}');
    }

    if (!keys.contains(key)) {
      throw ArgumentError.value('#${by.name}', 'by',
          '\'$key\' does not match any persisting field in ${(E).toString()}');
    }

    return database
        .select('SELECT * FROM $tableName ORDER BY $key $ordering')
        .map(deserialize);
  }

  @override
  bool contains(Object? element) {
    if (element is! E) return false;
    final result = database.select(
        'SELECT EXISTS(SELECT 1 FROM $tableName WHERE id = ?)',
        [element.id.toBytes()]);
    return result.boolValue;
  }

  @override
  bool add(Object? value) {
    if (value is! E || contains(value)) return false;
    database.execute(
        'INSERT INTO $tableName (${keys.join(', ')}) '
        'VALUES (${keys.map(constant('?')).join(', ')})',
        value.toMap().values.toList());
    return true;
  }

  /// Updates [element] on the Set.
  ///
  /// Elements are matched by their uuid [identity], not equality.
  ///
  /// Returns `true` if [element] was updated. If the `element` isn't in the
  /// set, returns `false` and the set is not changed.
  bool update(E element) => remove(element) ? add(element) : false;

  @override
  bool remove(Object? value) {
    if (value is! E || !contains(value)) return false;
    database.execute(
      'DELETE FROM $tableName WHERE id = ?',
      [value.id.toBytes()],
    );
    return true;
  }

  /// Creates a [Set] with the same elements as this [TableSet].
  ///
  /// The returned [Set] will _not_ modify the [Database].
  @override
  Set<E> toSet() =>
      database.select('SELECT * FROM $tableName').map(deserialize).toSet();

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

  @internal
  Map<String, Datatype> get keyTypes => Persistable.of<E>().persistingKeyTypes;

  @internal
  Iterable<String> get keys => keyTypes.keys;

  @internal
  E deserialize(JsonMap map) => Serializable.of<E>().fromMap(map) as E;
}
