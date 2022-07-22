import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stack_trace/stack_trace.dart' as stacktrace;
import 'package:rollbar_common/rollbar_common.dart';

import '../data/payload/frame.dart' as rollbar;

extension _Sig on RegExp {
  static final RegExp dso = RegExp(r'(\n|^)isolate_dso_base:');
  static final RegExp inst = RegExp(r'(\n|^)isolate_instructions:');
  static final RegExp nativeFrame = RegExp(r'^ *#[0-9]+ ');
}

@internal
extension TraceAdapter on StackTrace {
  bool get isNative => [_Sig.dso, _Sig.inst].all(toString().contains);

  /// The original, unparsed trace. It will only be present when the original
  /// trace might require further backend processing, eg. symbolication.
  /// Otherwise this value will be `null`.
  String? get rawTrace => isNative ? toString() : null;

  List<rollbar.Frame> get frames =>
      toTrace().frames.map(rollbar.Frame.from).toList();

  stacktrace.Trace toTrace() {
    if (isNative) {
      final frames = LineSplitter.split(toString())
          .where((line) => line.contains(_Sig.nativeFrame))
          .map((line) => stacktrace.Frame.parseVM(line.trimLeft()));

      return stacktrace.Trace(frames);
    }

    return stacktrace.Trace.from(this);
  }
}

@internal
extension FrameExtensions on stacktrace.Frame {
  /// The full path to the file in which the code is located.
  String get path => Uri.parse(uri.toString()).path;

  /// The type the member belongs to.
  String? get type => member.flatMap(
      (member) => member.contains('.') ? member.splitOnce('.').first : null);

  String? get method => member.flatMap(
      (member) => member.contains('.') ? member.splitOnce('.').second : member);
}
