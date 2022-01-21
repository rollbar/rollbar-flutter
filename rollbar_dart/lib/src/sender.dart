import 'api/response.dart';

/// Sender interface to send payload data to Rollbar.
abstract class Sender {
  Future<Response?> send(Map<String, dynamic>? payload);
  Future<Response?> sendString(String payload);
}
