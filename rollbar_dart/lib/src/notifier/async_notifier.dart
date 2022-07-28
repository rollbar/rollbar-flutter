import 'package:meta/meta.dart';
import 'package:rollbar_dart/rollbar_dart.dart';

/// A class that performs the core functions for the notifier:
/// - Prepare a payload from the provided error or message.
/// - Apply the configured transformation, if any.
/// - Send the occurrence payload to Rollbar via a [Sender].
@sealed
@immutable
class AsyncNotifier implements Notifier {
  @override
  final Sender sender;

  @override
  final Wrangler wrangler;

  AsyncNotifier(Config config)
      : wrangler = config.wrangler(config),
        sender = config.sender(config);

  @override
  Future<void> notify(Event event) async {
    final payload = await wrangler.payload(from: event);
    await sender.send(payload.toMap());
  }

  @override
  void dispose() {}
}
