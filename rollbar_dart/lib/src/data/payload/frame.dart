import 'package:meta/meta.dart';
import 'package:stack_trace/stack_trace.dart' as trace;
import 'package:rollbar_common/rollbar_common.dart';

import '../../ext/trace.dart';

/// Contains the information of a single frame in a stack trace.
@sealed
@immutable
class Frame implements Serializable {
  final String filename;
  final String? type;
  final String? method;
  final int? line;
  final int? column;

  const Frame({
    required this.filename,
    this.type,
    this.method,
    this.line,
    this.column,
  });

  factory Frame.from(trace.Frame frame) => Frame(
      filename: frame.path,
      type: frame.type,
      method: frame.method,
      line: frame.line,
      column: frame.column);

  factory Frame.fromMap(JsonMap map) => Frame(
      filename: map['filename'],
      method: map['method'],
      type: map['class_name'],
      line: map['lineno'],
      column: map['colno']);

  String get location => [
        filename,
        line == null && column != null ? '???' : line,
        column,
      ].where(isNotNull).join(':');

  String get member => [
        type,
        method ?? '???',
      ].where(isNotNull).join('.');

  @override
  String toString() => [
        'Frame: ',
        if (member.isNotEmpty) '$member ',
        '($location)',
      ].join();

  @override
  JsonMap toMap() => {
        'filename': filename,
        'class_name': type,
        'method': method,
        'lineno': line,
        'colno': column,
      }.compact();
}
