import 'package:stack_trace/stack_trace.dart' as trace;
import '../../ext/collections.dart';

/// Contains the information of a single frame in a stack trace.
class Frame {
  int? colno;
  int? lineno;
  String? method;
  String? filename;
  String? className;

  Frame();

  factory Frame.fromMap(JsonMap map) => Frame()
    ..colno = map['colno']
    ..lineno = map['lineno']
    ..method = map['method']
    ..filename = map['filename']
    ..className = map['class_name'];

  factory Frame.from(trace.Frame frame) => Frame()
    ..colno = frame.column
    ..lineno = frame.line
    ..method = frame.member
    ..filename = Uri.parse(frame.uri.toString()).path;

  JsonMap toMap() => {
        'colno': colno,
        'lineno': lineno,
        'method': method,
        'filename': filename,
        'class_name': className,
      }..removeWhere((k, v) => v == null);
}
