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
  FutureOr<void> notify(Occurrence event) async {
    if (event.reading != null) {
      telemetry.register(event.reading as Reading);
    } else {
      final payload = await wrangler.payload(
        event: event.copyWith(telemetry: telemetry),
      );
      await sender.send(payload.toMap());
    }
  }

  @override
  void dispose() {}
}
