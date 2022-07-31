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

  AsyncNotifier(Config config)
      : wrangler = config.wrangler(config),
        sender = config.sender(config);

  @override
  FutureOr<void> notify(Event event) async {
    final payload = await wrangler.payload(from: event);
    await sender.send(payload.toMap());
  }

  @override
  void dispose() {}
}
