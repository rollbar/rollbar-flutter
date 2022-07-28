import 'dart:io' show Platform;

import 'package:meta/meta.dart';

import '../data/payload/body.dart';
import '../data/payload/client.dart';
import '../data/payload/data.dart';
import '../data/payload/payload.dart';
import '../data/event.dart';
import '../data/config.dart';
import '../transformer/transformer.dart';
import '../notifier/notifier.dart';
import 'wrangler.dart';

/// Prepares the payload data in a Rollbar-friendly format for the [Sender].
@sealed
@immutable
class DataWrangler implements Wrangler {
  @override
  final Transformer transformer;
  final Config config;

  DataWrangler(this.config) : transformer = config.transformer.call(config);

  @override
  Future<Payload> payload({required Event from}) async {
    final event = from;
    final body = Body.from(event: event);
    final data = await _dataFrom(event, body);
    return Payload(config.accessToken, data);
  }

  Future<Data> _dataFrom(Event event, Body body) async {
    final data = Data(
        body: body,
        timestamp: DateTime.now().microsecondsSinceEpoch,
        language: 'dart',
        level: event.level,
        platform: Platform.operatingSystem,
        framework: config.framework,
        codeVersion: config.codeVersion,
        client: Client.fromPlatform(),
        environment: config.environment,
        notifier: {'version': Notifier.version, 'name': Notifier.name},
        server: {'root': config.package});

    return await transformer.transform(event, data);
  }
}
