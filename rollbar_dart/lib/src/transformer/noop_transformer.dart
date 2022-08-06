import 'package:meta/meta.dart';

import '../data/payload/data.dart';
import '../config.dart';
import '../event.dart';
import 'transformer.dart';

@sealed
@immutable
@internal
class NoopTransformer implements Transformer {
  const NoopTransformer(Config _);

  @override
  Data transform(Data data, {required Event event}) => data;
}
