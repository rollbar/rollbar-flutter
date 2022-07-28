import 'dart:async';

import 'package:rollbar_dart/rollbar_dart.dart';

abstract class Notifier {
  // notifier version to be updated with each new release: [todo] automate
  static const version = '0.3.0-beta';
  static const name = 'rollbar-dart';

  Sender get sender;
  Wrangler get wrangler;

  FutureOr<void> notify(Event event);
  FutureOr<void> dispose();
}
