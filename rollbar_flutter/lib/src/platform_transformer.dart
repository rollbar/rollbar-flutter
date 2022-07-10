import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show PlatformException;
import 'package:rollbar_dart/rollbar.dart'
    show Body, Data, TraceChain, TraceInfo, Transformer;

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
    if (error is PlatformException) {
      if (Platform.isAndroid) {
        _enrichAndroidTrace(error, data);
      }
    }

    if (wrapped != null) {
      return await wrapped!.transform(error, trace, data);
    }

    return data;
  }

  static const String androidTracePayloadPrefix =
      'com.rollbar.flutter.RollbarTracePayload:';

  void _enrichAndroidTrace(PlatformException error, Data data) {
    // We cannot use error.stackTrace here, it will contain
    // 'com.rollbar.flutter.RollbarTracePayload:' only in debug mode, but not
    // in release
    if (error.message!.startsWith(androidTracePayloadPrefix)) {
      var message = error.message!.substring(androidTracePayloadPrefix.length);
      _attachPlatformPayload(message, data);
    }
  }

  void _attachPlatformPayload(String message, Data data) {
    final embeddedPayload = jsonDecode(message) as Map;
    final embeddedBody = embeddedPayload['data']['body'] as Map;

    if (appendToChain) {
      data.body = _prependPlatformTraceToChain(data.body, embeddedBody);
    } else {
      data.platformPayload = embeddedPayload;
      _restoreDartChainMessage(
          data.body.traces, Body.fromMap(embeddedBody)?.traces);
    }
  }

  Body _prependPlatformTraceToChain(Body dartBody, Map embeddedBody) {
    final embeddedChain = Body.fromMap(embeddedBody)!.traces!;
    final dartChain = dartBody.traces!;

    _restoreDartChainMessage(dartChain, embeddedChain);

    embeddedChain.addAll(dartChain);
    return TraceChain()..traces = embeddedChain;
  }

  // Fix message, we hijacked it on the platform side to carry the payload
  void _restoreDartChainMessage(
    List<TraceInfo?>? dartChain,
    List<TraceInfo?>? embeddedChain,
  ) {
    if (embeddedChain?.isNotEmpty == true) {
      for (var element in dartChain!) {
        if (element!.exception != null &&
            element.exception!.message!.startsWith('PlatformException') &&
            element.exception!.message!.contains(androidTracePayloadPrefix)) {
          element.exception!.message =
              'PlatformException(error, "${embeddedChain![0]!.exception!.message}")';
        }
      }
    }
  }
}
