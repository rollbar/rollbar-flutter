import 'identifiable.dart';
import 'serializable.dart';

import 'record.dart';

/// A type identifier.
enum Datatype { uuid, integer, real, text, blob }

extension DatatypeSqlType on Datatype {
  /// An SQL-friendly type declaration.
  String get sqlTypeDeclaration {
    switch (this) {
      case Datatype.uuid:
        return 'BINARY(16) NOT NULL PRIMARY KEY';
      default:
        return toString().split('.').last.toUpperCase() + ' NOT NULL';
    }
  }
}

/// The class of types that are [Persistable].
///
/// [Persistable] types leverage serialization to store and recover
/// `(key, value)` pairs through [Serializable.fromMap] and [toMap].
abstract class Persistable<T extends Object>
    implements Serializable, Identifiable<T> {
  static const _map = <Type, PersistableFor>{
    Persistable: PersistableFor(),
    Record: PersistableRecord(),
  };

  static PersistableFor of<T extends Persistable>() => _map[T]!;

  /// A List of all persistable keys and their associated [Datatype]s in
  /// this [Persistable].
  // static Map<String, Datatype> get persistingKeyTypes;
}

/// Dart's type system is too rudimentary and still doesn't support
/// abstract static interfaces.
///
/// This is a workaround that allows us to express generic [Serializable]
/// types.
///
/// More info: https://github.com/dart-lang/language/issues/356
class PersistableFor {
  const PersistableFor();

  Map<String, Datatype> get persistingKeyTypes =>
      throw NoSuchMethodError.withInvocation(
          this, Invocation.getter(#persistingKeys));
}
