import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rollbar_dart/rollbar_dart.dart';

@sealed
abstract class Notifier {
  // notifier version to be updated with each new release: [todo] automate
  static const version = '1.1.0';
  static const name = 'rollbar-dart';

  FutureOr<Context> notify(Context state, final Event event);
}
