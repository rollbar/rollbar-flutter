/// Sender interface to send payload data to Rollbar.
abstract class Sender {
  /// Sends the specified payload.
  /// Returns `true` if sent successfully.
  Future<bool> send(Map<String, dynamic>? payload);

  /// Sends the specified payload.
  /// Returns `true` if sent successfully.
  Future<bool> sendString(String payload);
}
