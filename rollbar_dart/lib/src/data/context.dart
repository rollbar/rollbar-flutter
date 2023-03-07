import 'package:meta/meta.dart';

import 'payload/user.dart';
import '../notifier/core_notifier.dart';
import 'config.dart';
import '../telemetry.dart';
import '../persistence.dart';

/// The library's contextual data, [Context] represents the library's state.
///
/// Some values may not persist throughout runs, this depends on whether their
/// class was declared with [Persistence].
///
/// [Context] is mutable by desigm to allow for in-place mutation. State
/// manipulation ought to occur in an encapsulated and controlled manner.
/// See [CoreNotifier].
@sealed
class Context implements Configurable {
  @override
  final Config config;
  final Telemetry telemetry;
  User? user;

  Context(this.config, {this.user, Telemetry? telemetry})
      : telemetry = telemetry ?? Telemetry(config);
}
