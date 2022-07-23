import 'identifiable.dart';
import 'serializable.dart';

/// The class of types that are [Persistable].
abstract class Persistable<T extends Object>
    implements Serializable, Identifiable<T> {
  /// A list of all persistable values in this [Object].
  List get values;
}
