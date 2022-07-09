import '../ext/collections.dart';
import '../rollbar_infrastructure.dart';

/// Sender interface to send payload data to Rollbar.
abstract class Sender {
  /// Sends the specified payload.
  ///
  /// Returns `true` if sent successfully.
  Future<bool> send(JsonMap payload, PayloadProcessing? processor);

  /// Sends the specified payload.
  ///
  /// Returns `true` if sent successfully.
  Future<bool> sendString(String payload, PayloadProcessing? processor);
}
