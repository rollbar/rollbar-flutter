import 'dart:convert';

import 'package:stack_trace/stack_trace.dart';

final _dsoSignature = RegExp(r'(\n|^)isolate_dso_base:');
final _instrSignature = RegExp(r'(\n|^)isolate_instructions:');
final _nativeFrameSignature = RegExp(r'^ *#[0-9]+ ');

Future<ParseTraceResult> parseTrace(StackTrace stackTrace) async {
  var traceString = stackTrace.toString();

  if (traceString.contains(_dsoSignature) &&
      traceString.contains(_instrSignature)) {
    return _parseNativeTrace(traceString);
  } else {
    return ParseTraceResult()
      ..trace = Trace.from(stackTrace)
      ..rawTrace = null;
  }
}

ParseTraceResult _parseNativeTrace(String traceString) {
  var parsedLines = LineSplitter.split(traceString);

  var frames = <Frame>[];
  for (var line in parsedLines) {
    if (line.contains(_nativeFrameSignature)) {
      frames.add(Frame.parseVM(line.trimLeft()));
    }
  }

  return ParseTraceResult()
    ..trace = Trace(frames)
    ..rawTrace = traceString;
}

class ParseTraceResult {
  Trace trace;

  /// The original, unparsed trace. It will only be present when the original trace
  /// might require further backend processing, eg. symbolication. Otherwise this
  /// value will be null.
  String rawTrace;
}
