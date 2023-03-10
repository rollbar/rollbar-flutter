import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rollbar_dart/rollbar_dart.dart';

/// An await/async-based [Sandbox].
///
/// This is especially useful for unit testing in order to avoid the [Isolate]
/// dance, and in cases where users may want to actual threads from being
/// spawned, which the [IsolatedNotifier] might do.
@sealed
@internal
class AsyncSandbox implements Sandbox<Context, Event> {
  @override
  Context get state => _state;

  final Notifier notifier;
  Context _state;

  AsyncSandbox(final Config config)
      : _state = Context(config),
        notifier = config.notifier(config);

  @override
  Future<void> dispatch(final Event event) async {
    _state = await notifier.notify(state, event);
  }

  @override
  void dispose() {}
}
