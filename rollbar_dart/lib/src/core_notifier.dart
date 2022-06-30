import 'dart:io' show Platform;
import '../../rollbar.dart';
import 'ext/collections.dart';

/// A class that performs the core functions for the notifier:
/// - Prepare a payload from the provided error or message.
/// - Apply the configured transformation, if any.
/// - Send the occurrence payload to Rollbar via a [Sender].
class CoreNotifier {
  final Config _config;
  final Sender _sender;
  final Transformer? _transformer;

  // notifierVersion to be updated with each new release:
  static const notifierVersion = '0.3.0-beta';
  static const notifierName = 'rollbar-dart';

  CoreNotifier(this._config)
      : _sender = _config.sender(_config),
        _transformer = _config.transformer?.call(_config);

  Future<void> log(
    Level level,
    dynamic error,
    StackTrace? stackTrace,
    String? message,
  ) async {
    final client = Client()
      ..locale = Platform.localeName
      ..hostname = Platform.localHostname
      ..os = Platform.operatingSystem
      ..osVersion = Platform.operatingSystemVersion
      ..rootPackage = _config.package
      ..dart = {'version': Platform.version};

    var data = Data()
      ..body = Body.from(message, error, stackTrace)
      ..timestamp = DateTime.now().microsecondsSinceEpoch
      ..language = 'dart'
      ..level = level
      ..platform = Platform.operatingSystem
      ..framework = _config.framework
      ..codeVersion = _config.codeVersion
      ..client = client
      ..environment = _config.environment
      ..notifier = {'version': notifierVersion, 'name': notifierName}
      // Root detection compatibility, currently checked under the server element
      ..server = {'root': client.rootPackage}.compact();

    if (_transformer != null) {
      data = await _transformer!.transform(error, stackTrace, data);
    }

    final payload = Payload()
      ..accessToken = _config.accessToken
      ..data = data;

    await _sender.send(payload.toMap());
  }
}
