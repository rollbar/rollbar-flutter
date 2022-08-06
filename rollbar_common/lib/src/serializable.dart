import 'package:collection/collection.dart';

import 'data/payload_record.dart';
import 'data/breadcrumb_record.dart';

typedef JsonMap = Map<String, dynamic>;

/// The class of types that are [Serializable].
abstract class Serializable {
  static const _map = <Type, SerializableFor>{
    Serializable: SerializableFor(),
    PayloadRecord: SerializablePayloadRecord(),
    BreadcrumbRecord: SerializableBreadcrumbRecord(),
  };

  static SerializableFor of<T extends Serializable>() => _map[T]!;

  //factory Serializable.fromMap(JsonMap map); // Not supported by Dart

  JsonMap toMap();
}

/// Dart's type system is too rudimentary and still doesn't support
/// abstract static interfaces.
///
/// This is a workaround that allows us to express generic [Serializable]
/// types.
///
/// More info: https://github.com/dart-lang/language/issues/356
class SerializableFor {
  const SerializableFor();

  Serializable fromMap(JsonMap map) {
    throw NoSuchMethodError.withInvocation(
        this, Invocation.method(#fromMap, [map]));
  }
}

abstract class Equatable {
  @override
  int get hashCode;

  @override
  bool operator ==(Object other);
}

mixin EquatableSerializableMixin implements Serializable, Equatable {
  static const _eq = DeepCollectionEquality();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Serializable && _eq.equals(toMap(), other.toMap());

  @override
  int get hashCode => Object.hashAll(
      toMap().values.map((e) => e is Map || e is Iterable ? _eq.hash(e) : e));
}
