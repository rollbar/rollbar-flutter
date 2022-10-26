import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

import 'exception_info.dart';
import 'breadcrumb.dart';
import 'frame.dart';

@immutable
mixin Report implements Equatable, Serializable {
  bool get isTrace => this is Trace || this is Traces;

  static Report fromMap(JsonMap map) {
    if (map.containsKey('message')) return Message.fromMap(map);
    if (map.containsKey('trace')) return Trace.fromMap(map);
    if (map.containsKey('trace_chain')) return Traces.fromMap(map);
    throw StateError('Map needs a message, trace or trace_chain, found none.');
  }

  Iterable<Trace> get traces {
    if (this is Trace) return [this as Trace];
    if (this is Traces) return (this as Traces).traces;
    throw StateError('$runtimeType is neither Trace nor Traces.');
  }
}

@sealed
@immutable
class Body with EquatableSerializableMixin implements Equatable, Serializable {
  final Iterable<Breadcrumb> telemetry;
  final Report report;

  const Body({required this.telemetry, required this.report});

  factory Body.fromMap(JsonMap map) => Body(
        telemetry: map.telemetry,
        report: Report.fromMap(map),
      );

  Body copyWith({
    Iterable<Breadcrumb>? telemetry,
    Report? report,
  }) =>
      Body(
          telemetry: telemetry ?? this.telemetry,
          report: report ?? this.report);

  @override
  JsonMap toMap() => {
        'telemetry': telemetry.map((breadcrumb) => breadcrumb.toMap()).toList(),
        ...report.toMap(),
      };
}

/// An individual error with its corresponding stack trace if available.
@sealed
@immutable
class Trace with Report, EquatableSerializableMixin {
  final ExceptionInfo exception;
  final Iterable<Frame> frames;
  final String? rawTrace;

  const Trace({
    required this.exception,
    this.frames = const [],
    this.rawTrace,
  });

  factory Trace.fromMap(JsonMap map) => Trace(
      exception: map.trace.exception,
      frames: map.trace.frames,
      rawTrace: map.trace.rawTrace);

  Trace copyWith({
    ExceptionInfo? exception,
    List<Frame>? frames,
    String? rawTrace,
  }) =>
      Trace(
          exception: exception ?? this.exception,
          frames: frames ?? this.frames,
          rawTrace: rawTrace ?? this.rawTrace);

  @override
  JsonMap toMap() => {
        'trace': {
          'frames': frames.map((frame) => frame.toMap()).toList(),
          'exception': exception.toMap(),
          'raw': rawTrace,
        }.compact()
      };
}

/// A chain of multiple errors, where the first one on the list represents the
/// root cause of the error.
@sealed
@immutable
class Traces with Report, EquatableSerializableMixin {
  @override
  final Iterable<Trace> traces;

  const Traces(this.traces);

  factory Traces.fromMap(JsonMap map) => Traces(
        map.traces.map((trace) => Trace.fromMap({'trace': trace})).toList(),
      );

  @override
  JsonMap toMap() => {
        'trace_chain': traces.map((t) => t.toMap().trace).toList(),
      };
}

/// A text message to be sent to Rollbar.
@sealed
@immutable
class Message with Report, EquatableSerializableMixin {
  final String text;

  const Message({required this.text});

  factory Message.fromMap(JsonMap map) => Message(text: map.message);

  @override
  JsonMap toMap() => {
        'message': {'body': text}
      };
}

extension _KeyValuePaths on JsonMap {
  ExceptionInfo get exception => ExceptionInfo.fromMap(this['exception']);
  String get message => this['message']['body'];
  String? get rawTrace => this['raw'];
  JsonMap get trace => this['trace'];

  Iterable<Breadcrumb> get telemetry => this['telemetry']
      .whereType<JsonMap>()
      .map<Breadcrumb>(Breadcrumb.fromMap)
      .toList();
  Iterable<Frame> get frames => this['frames'] //
      .whereType<JsonMap>()
      .map<Frame>(Frame.fromMap)
      .toList();
  Iterable<JsonMap> get traces => this['trace_chain'].whereType<JsonMap>();
}
