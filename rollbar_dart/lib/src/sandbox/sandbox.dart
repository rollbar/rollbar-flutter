import 'dart:async';

/// Defines a boundary between the external world and a self-contained world.
///
/// [State] is defined as an associated type to the Sandbox, it
/// the state of the sandbox.
abstract class Sandbox<State, Element> {
  FutureOr<State> get state;

  FutureOr<void> dispatch(final Element e);
  FutureOr<void> dispose();
}
