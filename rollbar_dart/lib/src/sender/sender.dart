import 'package:rollbar_common/rollbar_common.dart';

/// Sender interface to send payload data to Rollbar.
abstract class Sender {
  /// Sends the specified payload.
  ///
  /// Returns `true` if sent successfully.
  Future<bool> send(final JsonMap payload);

  /// Sends the specified payload.
  ///
  /// Returns `true` if sent successfully.
  Future<bool> sendString(final String payload);
}
