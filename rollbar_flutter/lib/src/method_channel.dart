import 'package:flutter/services.dart';
import 'package:rollbar_flutter/rollbar_flutter.dart';

extension RollbarMethodChannel on MethodChannel {
  /// The platform-specific path where we can persist data if needed.
  Future<String> get persistencePath async =>
      await invokeMethod('persistencePath');

  /// Initializes the native Apple/Android SDK Rollbar notifier
  /// using the given configuration.
  Future<void> initialize({required Config config}) async =>
      await invokeMethod('initialize', config.toMap());

  /// Unwinds the native Apple/Android SDK Rollbar notifier.
  ///
  /// This is a no-op at the moment.
  Future<void> close() async => await invokeMethod('close');
}
