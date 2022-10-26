import 'dart:async';

import '../sender/sender.dart';
import '../wrangler/wrangler.dart';
import '../context.dart';
import '../telemetry.dart';
import '../event.dart';

abstract class Notifier {
  // notifier version to be updated with each new release: [todo] automate
  static const version = '1.0.0';
  static const name = 'rollbar-dart';

  Sender get sender;
  Wrangler get wrangler;
  Context get context;
  Telemetry get telemetry;

  FutureOr<void> notify(Event event);
  FutureOr<void> dispose();
}
