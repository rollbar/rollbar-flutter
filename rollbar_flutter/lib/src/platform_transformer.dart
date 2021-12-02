import 'dart:convert';

import 'package:flutter/services.dart' show PlatformException;
import 'package:rollbar_dart/rollbar.dart'
    show Body, Data, RollbarPlatformInfo, TraceChain, Transformer;
import 'package:rollbar_dart/src/api/payload/body.dart';

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
      if (RollbarPlatformInfo.isAndroid) {
        _enrichAndroidTrace(error, data);
      }
    }

    if (wrapped != null) {
      return await wrapped!.transform(error, trace, data);
    }

    return data;
  }

  static const String ANDROID_TRACE_PAYLOAD_PREFIX =
      'com.rollbar.flutter.RollbarTracePayload:';

  void _enrichAndroidTrace(PlatformException error, Data data) {
    // We cannot use error.stackTrace here, it will contain 'com.rollbar.flutter.RollbarTracePayload:'
    // only in debug mode, but not in release
    if (error.message!.startsWith(ANDROID_TRACE_PAYLOAD_PREFIX)) {
      var message =
          error.message!.substring(ANDROID_TRACE_PAYLOAD_PREFIX.length);
      _attachPlatformPayload(message, data);
    }
  }

  void _attachPlatformPayload(String message, Data data) {
    var embeddedPayload = jsonDecode(message);
    var embeddedBody = embeddedPayload['data']['body'] as Map?;

    if (appendToChain) {
      data.body = _prependPlatformTraceToChain(data.body, embeddedBody!);
    } else {
      data.platformPayload = embeddedPayload;
      _restoreDartChainMessage(
          data.body.getTraces(), Body.fromMap(embeddedBody!)!.getTraces()!);
    }
  }

  Body _prependPlatformTraceToChain(Body dartBody, Map embeddedBody) {
    var embeddedChain = Body.fromMap(embeddedBody)!.getTraces()!;

    var dartChain = dartBody.getTraces()!;

    _restoreDartChainMessage(dartChain, embeddedChain);

    embeddedChain.addAll(dartChain);
    return TraceChain()..traces = embeddedChain;
  }

  // Fix message, we hijacked it on the platform side to carry the payload
  void _restoreDartChainMessage(
      List<TraceInfo?>? dartChain, List<TraceInfo?> embeddedChain) {
    if (embeddedChain.isNotEmpty) {
      dartChain!.forEach((element) {
        if (element!.exception != null &&
            element.exception!.message!.startsWith('PlatformException') &&
            element.exception!.message!.contains(ANDROID_TRACE_PAYLOAD_PREFIX)) {
          element.exception!.message =
              'PlatformException(error, "${embeddedChain[0]!.exception!.message}")';
        }
      });
    }
  }
}
