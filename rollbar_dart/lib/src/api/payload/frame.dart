import 'package:meta/meta.dart';
import 'package:stack_trace/stack_trace.dart' as trace;

import '../../ext/object.dart';
import '../../ext/collections.dart';

/// Contains the information of a single frame in a stack trace.
@sealed
@immutable
class Frame {
  final String filename;
  final String? type;
  final String? member;
  final int? line;
  final int? column;

  const Frame({
    required this.filename,
    this.type,
    this.member,
    this.line,
    this.column,
  });

  factory Frame.from(trace.Frame frame) {
    final sp = frame.member?.splitOnce('.');
    return Frame(
        filename: Uri.parse(frame.uri.toString()).path,
        type: sp?.first,
        member: sp?.second,
        line: frame.line,
        column: frame.column);
  }

  factory Frame.fromMap(JsonMap map) => Frame(
      filename: map['filename'],
      member: map['method'],
      type: map['class_name'],
      line: map['lineno'],
      column: map['colno']);

  @override
  String toString() => 'Frame($type.$member($filename:$line:$column))';

  JsonMap toMap() => {
        'filename': filename,
        'class_name': type,
        'method': member,
        'lineno': line,
        'colno': column,
      }..compact();
}

extension _Attributes on JsonMap {}
