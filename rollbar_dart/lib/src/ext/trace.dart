import 'dart:convert';
import 'package:stack_trace/stack_trace.dart';
import 'package:meta/meta.dart';
import 'collections.dart';

@internal
extension Signature on RegExp {
  static final RegExp dso = RegExp(r'(\n|^)isolate_dso_base:');
  static final RegExp inst = RegExp(r'(\n|^)isolate_instructions:');
  static final RegExp nativeFrame = RegExp(r'^ *#[0-9]+ ');
}

@internal
extension TraceAdapter on StackTrace {
  bool get isNative => [Signature.dso, Signature.inst].all(toString().contains);

  /// The original, unparsed trace. It will only be present when the original
  /// trace might require further backend processing, eg. symbolication.
  /// Otherwise this value will be `null`.
  String? get rawTrace => isNative ? toString() : null;

  List<Frame> get frames => toTrace().frames;

  Trace toTrace() {
    if (isNative) {
      final frames = LineSplitter.split(toString())
          .where((line) => line.contains(Signature.nativeFrame))
          .map((line) => Frame.parseVM(line.trimLeft()));

      return Trace(frames);
    }

    return Trace.from(this);
  }
}
