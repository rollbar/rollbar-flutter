import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rollbar_dart/rollbar_dart.dart';

@sealed
@immutable
class AsyncNotifier implements Notifier {
  @override
  final Sender sender;

  @override
  final Wrangler wrangler;

  @override
  final Telemetry telemetry;

  AsyncNotifier(Config config)
      : wrangler = config.wrangler(config),
        sender = config.sender(config),
        telemetry = Telemetry(config);

  @override
  FutureOr<void> notify(Event event) async {
    // [todo] this is awful.
    if (event.reading != null) {
      telemetry.register(event.reading!); // [todo] this is awful.
    } else {
      // [todo] this is all awful.
      final eventWithTelemetry = event.copyWith(telemetry: telemetry);
      final payload = await wrangler.payload(event: eventWithTelemetry);
      await sender.send(payload.toMap());
    }
  }

  @override
  void dispose() {}
}
