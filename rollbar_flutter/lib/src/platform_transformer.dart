import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:rollbar_dart/rollbar.dart'
    show Body, Data, TraceChain, TraceInfo, Transformer;

typedef JsonMap = Map<String, dynamic>;

/// Free function to create the transformer.
///
/// Free and static functions are the only way we can pass factories to
/// different isolates, which we need to be able to do to register uncaught
/// error handlers.
Transformer platformTransformer(_) => PlatformTransformer();

/// This trasformer inspects some platform specific exception types, which
/// carry additional occurrence details in their exception messages.
/// This allows the Rollbar Dart notifier to report a complete trace including
/// both platform specific and Dart frames.
class PlatformTransformer implements Transformer {
  final Transformer? wrapped;
  final bool appendToChain;

  PlatformTransformer({this.wrapped, this.appendToChain = false});

  @override
  Future<Data> transform(dynamic error, StackTrace? trace, Data data) async {
    if (defaultTargetPlatform == TargetPlatform.android &&
        error is PlatformException) {
      data = _enrichAndroidTrace(error.message, data);
    }

    return await wrapped?.transform(error, trace, data) ?? data;
  }
}

extension _AndroidPlatform on PlatformTransformer {
  static const String tracePayloadPrefix =
      'com.rollbar.flutter.RollbarTracePayload:';

  Data _enrichAndroidTrace(String? rawPayload, Data data) {
    // We cannot use error.stackTrace here, it will contain
    // 'com.rollbar.flutter.RollbarTracePayload:' only in debug mode,
    // but not in release.
    if (rawPayload?.startsWith(tracePayloadPrefix) == true) {
      final payload = rawPayload!.substring(tracePayloadPrefix.length);
      return _attachPlatformPayload(jsonDecode(payload), data);
    }

    return data;
  }

  Data _attachPlatformPayload(JsonMap payload, Data data) {
    final embeddedBody = payload['data']['body'] as JsonMap;

    if (appendToChain) {
      final body = _appendPlatformTraceToChain(data.body, embeddedBody);
      return data.copyWith(body: body);
    } else {
      _restoreDartChainMessage(
        data.body.traces,
        Body.fromMap(embeddedBody).traces,
      );
      return data.copyWith(platformPayload: payload);
    }
  }

  Body _appendPlatformTraceToChain(Body dartBody, JsonMap embeddedBody) {
    final embeddedChain = Body.fromMap(embeddedBody).traces;
    final dartChain = dartBody.traces;

    _restoreDartChainMessage(dartChain, embeddedChain);

    embeddedChain.addAll(dartChain);
    return TraceChain(embeddedChain);
  }

  // Fix message, we hijacked it on the platform side to carry the payload
  void _restoreDartChainMessage(
    List<TraceInfo> dartChain,
    List<TraceInfo> embeddedChain,
  ) {
    if (embeddedChain.isEmpty) return;
    final originalMessage = embeddedChain.first.exception.message;
    final message = 'PlatformException(error, "$originalMessage")';

    for (final element in dartChain) {
      if (element.exception.message.startsWith('PlatformException') &&
          element.exception.message.contains(tracePayloadPrefix)) {
        element.exception.message = message;
      }
    }
  }
}
