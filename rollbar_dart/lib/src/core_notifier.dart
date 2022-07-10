import 'dart:io' show Platform;
import '../../rollbar.dart';

/// A class that performs the core functions for the notifier:
/// - Prepare a payload from the provided error or message.
/// - Apply the configured transformation, if any.
/// - Send the occurrence payload to Rollbar via a [Sender].
class CoreNotifier {
  final Sender _sender;
  final Transformer? _transformer;

  // notifierVersion to be updated with each new release:
  static const version = '0.3.0-beta';
  static const name = 'rollbar-dart';

  CoreNotifier()
      : _sender = Rollbar.config.sender(Rollbar.config),
        _transformer = Rollbar.config.transformer?.call(Rollbar.config);

  Future<void> log(
    Level level,
    dynamic error,
    StackTrace? stackTrace,
    String? message,
    PayloadProcessing processor,
  ) async {
    var data = Data()
      ..body = Body.from(message, error, stackTrace)
      ..timestamp = DateTime.now().microsecondsSinceEpoch
      ..language = 'dart'
      ..level = level
      ..platform = Platform.operatingSystem
      ..framework = Rollbar.config.framework
      ..codeVersion = Rollbar.config.codeVersion
      ..client = Client.fromPlatform()
      ..environment = Rollbar.config.environment
      ..notifier = {'version': CoreNotifier.version, 'name': CoreNotifier.name}
      ..server = {'root': Rollbar.config.package};

    if (_transformer != null) {
      data = await _transformer!.transform(error, stackTrace, data);
    }

    final payload = Payload(
      accessToken: Rollbar.config.accessToken,
      data: data,
    );

    await _sender.send(payload.toMap(), processor);
  }
}
