import 'extension/collection.dart';

import 'record.dart';

/// The class of types that are [Serializable].
abstract class Serializable {
  static const _map = <Type, SerializableFor>{
    Serializable: SerializableFor(),
    Record: SerializableRecord(),
  };

  static SerializableFor of<T extends Serializable>() => _map[T]!;

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
