import 'dart:async';

import '../transformer/transformer.dart';
import '../data/payload/payload.dart';
import '../data/event.dart';

abstract class Wrangler {
  Transformer get transformer;

  FutureOr<Payload> payload({required Event from});
}
