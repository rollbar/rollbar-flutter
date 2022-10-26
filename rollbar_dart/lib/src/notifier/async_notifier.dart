import 'dart:async';

import 'package:meta/meta.dart';

import '../data/payload/breadcrumb.dart';
import '../sender/sender.dart';
import '../wrangler/wrangler.dart';
import '../config.dart';
import '../context.dart';
import '../event.dart';
import '../telemetry.dart';
import 'notifier.dart';

@sealed
@immutable
@internal
class AsyncNotifier implements Notifier {
  @override
  final Sender sender;

  @override
  final Wrangler wrangler;

  @override
  final Context context;

  @override
  final Telemetry telemetry;

  AsyncNotifier(Config config)
      : wrangler = config.wrangler(config),
        sender = config.sender(config),
        context = Context(),
        telemetry = Telemetry(config);

  @override
  FutureOr<void> notify(Event event) async {
    if (event.user != null) {
      context.user = event.user;
    } else if (event.breadcrumb != null) {
      telemetry.add(event.breadcrumb as Breadcrumb);
    } else {
      telemetry.removeExpired();

      final payload = await wrangler.payload(
        event: event.copyWith(context: context, telemetry: telemetry),
      );
      await sender.send(payload.toMap());
    }
  }

  @override
  void dispose() {}
}
