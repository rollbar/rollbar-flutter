import 'dart:async';
import '../data/payload/data.dart';
import '../occurrence.dart';

/// Represents a transformation operation on a Rollbar [Data] object.
abstract class Transformer {
  /// Transform the occurrence data.
  ///
  /// Implementations are free to mutate the [Data] object they receive,
  /// reuse some of its parts, or create an entirely new object, but a
  /// `Data` instance *must* be returned in all cases.
  FutureOr<Data> transform(Data data, {required Occurrence event});
}
