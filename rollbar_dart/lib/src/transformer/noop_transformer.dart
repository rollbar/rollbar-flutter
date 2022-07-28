import 'package:meta/meta.dart';

import '../data/payload/data.dart';
import '../config.dart';
import '../data/event.dart';
import 'transformer.dart';

@sealed
@immutable
class NoopTransformer implements Transformer {
  const NoopTransformer(Config _);

  @override
  Data transform(Event _, Data data) => data;
}
