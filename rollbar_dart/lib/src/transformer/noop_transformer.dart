import 'package:meta/meta.dart';
import 'package:rollbar_dart/rollbar_dart.dart';

@sealed
@immutable
@internal
class NoopTransformer implements Transformer {
  const NoopTransformer(Config _);

  @override
  Data transform(Data data, {required Event event}) => data;
}
