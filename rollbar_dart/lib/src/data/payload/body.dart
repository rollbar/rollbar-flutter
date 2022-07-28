import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';
import '../../ext/trace.dart';
import '../event.dart';
import 'exception_info.dart';
import 'frame.dart';

typedef Traces = List<TraceInfo>;

/// Container class with the error or message to be sent to Rollbar.
abstract class Body {
  JsonMap toMap();
  Traces get traces;

  static Body get empty => Message();

  static Body fromMap(JsonMap attributes) {
    if (attributes.containsKey('trace')) {
      return TraceInfo.fromMap(attributes);
    } else if (attributes.containsKey('message')) {
      return Message.fromMap(attributes);
    } else {
      return TraceChain.fromMap(attributes);
    }
  }

  factory Body.from({required Event event}) {
    if (event.error == null && event.message == null) {
      throw ArgumentError(
          'Either an error or a message must be provided.', 'error');
    }

    if (event.error != null) {
      return TraceInfo(
          frames: event.stackTrace?.frames ?? [],
          exception: ExceptionInfo.from(event.error, event.message),
          rawTrace: event.stackTrace?.rawTrace);
    }

    return Message(event.message!);
  }
}

/// An individual error with its corresponding stack trace if available.
@immutable
class TraceInfo implements Body {
  final ExceptionInfo exception;
  final List<Frame> frames;
  final String? rawTrace;

  @override
  Traces get traces => [this];

  const TraceInfo({
    required this.exception,
    required this.frames,
    this.rawTrace,
  });

  factory TraceInfo.fromMap(JsonMap attributes) => TraceInfo(
      frames: attributes.trace.frames,
      exception: attributes.trace.exceptionInfo,
      rawTrace: attributes.trace.rawTrace);

  TraceInfo copyWith({
    ExceptionInfo? exception,
    List<Frame>? frames,
    String? rawTrace,
  }) =>
      TraceInfo(
          exception: exception ?? this.exception,
          frames: frames ?? this.frames,
          rawTrace: rawTrace ?? this.rawTrace);

  @override
  JsonMap toMap() => {
        'trace': {
          'frames': frames.map((f) => f.toMap()).toList(),
          'exception': exception.toMap(),
          'raw': rawTrace,
        }.compact()
      };
}

/// A chain of multiple errors, where the first one on the list represents the
/// root cause of the error.
@sealed
@immutable
class TraceChain implements Body {
  @override
  final Traces traces;

  const TraceChain(this.traces);

  @override
  JsonMap toMap() => {
        'trace_chain': traces.map((trace) => trace.toMap()['trace']).toList(),
      };

  factory TraceChain.fromMap(JsonMap attributes) => TraceChain(
        attributes.traceChain
            .map((trace) => TraceInfo.fromMap({'trace': trace}))
            .toList(),
      );
}

/// A text message to be sent to Rollbar.
@sealed
@immutable
class Message implements Body {
  final String text;

  const Message([this.text = '']);

  factory Message.fromMap(JsonMap attributes) => Message(attributes.message);

  @override
  Traces get traces => [];

  @override
  JsonMap toMap() => {
        'message': {
          'body': text,
        }
      };
}

extension _Attributes on JsonMap {
  ExceptionInfo get exceptionInfo {
    assert(containsKey('exception'));
    return ExceptionInfo.fromMap(this['exception'] as JsonMap);
  }

  String get message => this['message']['body'] ?? '';
  String? get rawTrace => this['raw'] as String?;
  JsonMap get trace => this['trace'] ?? {};

  List<JsonMap> get traceChain =>
      (this['trace_chain'] as List? ?? []).whereType<JsonMap>().toList();

  List<Frame> get frames =>
      (this['frames'] as List? ?? []).map((f) => Frame.fromMap(f)).toList();
}
