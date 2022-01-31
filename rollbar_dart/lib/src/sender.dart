/// Sender interface to send payload data to Rollbar.
abstract class Sender {
  Future<bool> send(Map<String, dynamic>? payload);
  Future<bool> sendString(String payload);
}
