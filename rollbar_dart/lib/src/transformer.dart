import 'data/payload/data.dart';

/// Represents a transformation operation on a Rollbar [Data] object.
abstract class Transformer {
  /// Transform the occurrence data.
  ///
  /// Implementations are free to mutate the [Data] object they receive,
  /// reuse some of its parts, or create an entirely new object, but a
  /// `Data` instance *must* be returned in all cases.
  Future<Data> transform(dynamic error, StackTrace? trace, Data data);
}
