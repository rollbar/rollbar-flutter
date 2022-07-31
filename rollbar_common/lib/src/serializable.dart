import 'extension/collection.dart';

import 'data/payload_record.dart';
import 'data/reading_record.dart';

/// The class of types that are [Serializable].
abstract class Serializable {
  static const _map = <Type, SerializableFor>{
    Serializable: SerializableFor(),
    PayloadRecord: SerializablePayloadRecord(),
    ReadingRecord: SerializableReadingRecord(),
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
