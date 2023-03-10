import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rollbar_dart/rollbar.dart';
import 'package:rollbar_dart/src/data/event.dart';

@sealed
@immutable
@internal
class CoreNotifier implements Notifier {
  final Sender sender;
  final Marshaller marshaller;
  final Transformer transformer;

  CoreNotifier(final Config config)
      : sender = config.sender(config),
        marshaller = config.marshaller(config),
        transformer = config.transformer(config);

  @override
  Future<Context> notify(Context context, final Event event) async {
    if (event is UserEvent) {
      context.user = event.user;
    } else if (event is TelemetryEvent) {
      context.telemetry.add(event.breadcrumb);
    } else if (event is Notification) {
      final data = marshaller.marshall(context: context, event: event);
      final transformedData = await transformer.transform(data, event: event);
      final payload = Payload(data: transformedData);

      await sender.send(payload.toMap());
    }

    return context;
  }
}
