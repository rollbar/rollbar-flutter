import 'dart:async';

import '../sender/sender.dart';
import '../wrangler/wrangler.dart';
import '../telemetry.dart';
import '../event.dart';

abstract class Notifier {
  // notifier version to be updated with each new release: [todo] automate
  static const version = '0.3.0-beta';
  static const name = 'rollbar-dart';

  Sender get sender;
  Wrangler get wrangler;
  Telemetry get telemetry;

  FutureOr<void> notify(Event event);
  FutureOr<void> dispose();
}
