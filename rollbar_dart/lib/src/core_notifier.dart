import 'dart:io' show Platform;

import 'package:rollbar_dart/src/trace.dart';
import 'package:rollbar_dart/src/transformer.dart';

import 'api/payload/body.dart';
import 'api/payload/client.dart';
import 'api/payload/data.dart';
import 'api/payload/exception_info.dart';
import 'api/payload/frame.dart' as rb;
import 'api/payload/level.dart';
import 'api/payload/payload.dart';
import 'api/response.dart';
import 'config.dart';
import 'sender.dart';

/// A class that performs the core functions for the notifier:
/// - Prepare a payload from the provided error or message.
/// - Apply the configured transformation, if any.
/// - Send the occurrence payload to Rollbar via a [Sender].
class CoreNotifier {
  final Config _config;
  final Sender? _sender;
  final Transformer? _transformer;

  // notifierVersion to be updated with each new release:
  static const notifierVersion = '0.2.0-beta';

  static const notifierName = 'rollbar-dart';

  CoreNotifier(this._config)
      : _sender = _make(_config, _config.sender),
        _transformer = _make(_config, _config.transformer);

  Future<Response?> log(Level level, dynamic error, StackTrace? stackTrace,
      String? message) async {
    var body = await _prepareBody(message, error, stackTrace);

    var client = Client()
      ..locale = Platform.localeName
      ..hostname = Platform.localHostname
      ..os = Platform.operatingSystem
      ..osVersion = Platform.operatingSystemVersion
      ..rootPackage = _config.package
      ..dart = {
        'version': Platform.version,
      };

    var data = Data()
      ..body = body
      ..timestamp = DateTime.now().microsecondsSinceEpoch
      ..language = 'dart'
      ..level = level
      ..platform = Platform.operatingSystem
      ..framework = _config.framework
      ..codeVersion = _config.codeVersion
      ..client = client
      ..environment = _config.environment
      ..notifier = {'version': notifierVersion, 'name': notifierName};

    if (client.rootPackage != null) {
      // Root detection compatibility, currently checked under the server element
      var server = {'root': client.rootPackage};

      data.server = server;
    }

    if (_transformer != null) {
      data = await _transformer!.transform(error, stackTrace, data);
    }

    var payload = Payload()
      ..accessToken = _config.accessToken
      ..data = data;

    return await _sender!.send(payload.toJson());
  }

  Future<Body> _prepareBody(
      String? message, dynamic error, StackTrace? stackTrace) async {
    if (error != null) {
      return await _prepareTracePayload(error, stackTrace, message);
    } else {
      return Message()..body = message;
    }
  }

  Future<TraceInfo> _prepareTracePayload(
      dynamic error, StackTrace? trace, String? description) async {
    var traceInfo = TraceInfo()
      ..exception = _getExceptionInfo(error, description);

    if (trace != null) {
      var parsedTrace = await parseTrace(trace);
      traceInfo.frames = parsedTrace.trace.frames.map((frame) {
        return rb.Frame()
          ..colno = frame.column
          ..lineno = frame.line
          ..method = frame.member
          ..filename = Uri.parse(frame.uri.toString()).path;
      }).toList();

      if (parsedTrace.rawTrace != null) {
        traceInfo.rawTrace = parsedTrace.rawTrace;
      }
    }

    return traceInfo;
  }

  static ExceptionInfo _getExceptionInfo(dynamic error, String? description) {
    ExceptionInfo result;
    if (error is ExceptionInfo) {
      result = error;
    } else {
      result = ExceptionInfo()
        ..clazz = error.runtimeType.toString()
        ..message = error.toString();
    }
    if (description != null) {
      result.description = description;
    }
    return result;
  }

  static T? _make<T>(Config config, T Function(Config)? factoryFunction) {
    if (factoryFunction == null) {
      return null;
    } else {
      return factoryFunction(config);
    }
  }
}
