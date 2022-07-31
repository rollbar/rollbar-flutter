import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:rollbar_common/rollbar_common.dart';
import 'package:rollbar_dart/rollbar.dart';
import 'extension/foundation.dart';

const String _prefix = 'com.rollbar.flutter.RollbarTracePayload:';

/// This trasformer inspects some platform specific exception types, which
/// carry additional occurrence details in their exception messages.
/// This allows the Rollbar Dart notifier to report a complete trace including
/// both platform specific and Dart frames.
class PlatformTransformer implements Transformer {
  final Transformer? wrapped;
  final bool append;

  PlatformTransformer({this.wrapped, this.append = false});

  @override
  Future<Data> transform(Event event, Data data) async {
    final error = event.error;
    if (defaultTargetPlatform.isAndroid &&
        error is PlatformException &&
        data.body.report.isTrace) {
      data = error.traces
          .map((extraTraces) =>
              data.body.report.traces.attach(extraTraces, append))
          .map((allTraces) => data.copyWith(
              body: data.body.copyWith(report: Traces(allTraces)),
              platformPayload: error.payload))
          .or(data);
    }

    return await wrapped?.transform(event, data) ?? data;
  }
}

extension _PlatformException on PlatformException {
  /// Retrieves the traces in the json payload inside PlatformException
  ///
  /// ¹On Android, [PlatformException.message] contains the entire exception
  /// payload in a json string.
  Iterable<Trace>? get traces =>
      (payload?['data']['body']).map(Report.fromMap)?.traces;

  JsonMap? get payload => message.mapIf(
      (rawPayload) => rawPayload.startsWith(_prefix),
      (rawPayload) => jsonDecode(rawPayload.substring(_prefix.length)));
}

extension _Message on Iterable<Trace> {
  /// Propagates the exception message from [extraTraces] to all traces and
  /// attaches the given [extraTraces] to this collection of traces.
  Iterable<Trace> attach(Iterable<Trace> extraTraces, bool append) =>
      (extraTraces.tryFirst?.exception.message)
          .map((message) => 'PlatformException(error, \'$message\')')
          .map(replaceExceptionMessages)
          .map(append ? extraTraces.followedBy : identity)
          .or(this);

  /// Propagates the given [message] as the new exception message, replacing
  /// only instances where the exception message is a json payload¹.
  Iterable<Trace> replaceExceptionMessages(String message) => mapWhere(
      (trace) => trace.exception.message.containsJsonPayload,
      (trace) => trace.copyWith(
          exception: trace.exception.copyWith(message: message)));
}

extension _String on String {
  bool get containsJsonPayload =>
      startsWith('PlatformException') && contains(_prefix);
}
