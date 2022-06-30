import '../../ext/collections.dart';
import '../../ext/trace.dart';
import 'exception_info.dart';
import 'frame.dart';

/// Container class with the error or message to be sent to Rollbar.
abstract class Body {
  JsonMap toMap();
  List<TraceInfo?>? get traces;

  static Body empty() => Message()..body = '';

  static Body? fromMap(Map attributes) {
    if (attributes.containsKey('trace')) {
      return TraceInfo.fromMap(attributes);
    } else if (attributes.containsKey('message')) {
      return Message.fromMap(attributes);
    } else {
      return TraceChain.fromMap(attributes);
    }
  }

  factory Body.from(
    String? message,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    if (error != null) {
      return TraceInfo()
        ..exception = ExceptionInfo.from(error, message)
        ..rawTrace = stackTrace?.rawTrace
        ..frames = stackTrace?.frames.map(Frame.from).toList();
    }

    return Message()..body = message;
  }
}

/// An individual error with its corresponding stack trace if available.
class TraceInfo implements Body {
  List<Frame>? frames;
  ExceptionInfo? exception;
  String? rawTrace;

  @override
  List<TraceInfo> get traces => [this];

  @override
  Map<String, dynamic> toMap() {
    var traceInfo = <String, dynamic>{
      'trace': <String, dynamic>{
        'frames': (frames ?? []).map((f) => f.toMap()).toList(),
      }
    };

    if (exception != null) {
      traceInfo['trace']['exception'] = exception!.toMap();
    }

    if (rawTrace != null) {
      traceInfo['trace']['raw'] = rawTrace;
    }

    return traceInfo;
  }

  static TraceInfo? fromMap(Map attributes) {
    if (!attributes.containsKey('trace')) {
      return null;
    }

    attributes = attributes['trace'];

    var result = TraceInfo();
    if (attributes.containsKey('frames')) {
      var frames = attributes['frames'];
      if (frames is List) {
        result.frames = frames.map((value) => Frame.fromMap(value)).toList();
      } else {
        throw ArgumentError('Frames is not a list: ${frames.runtimeType}');
      }
    }

    if (attributes.containsKey('exception')) {
      result.exception = ExceptionInfo.fromMap(attributes['exception']);
    }

    if (attributes.containsKey('raw')) {
      result.rawTrace = attributes['raw'];
    }

    return result;
  }
}

/// A chain of multiple errors, where the first one on the list represents the
/// root cause of the error.
class TraceChain implements Body {
  @override
  List<TraceInfo?>? traces;

  @override
  JsonMap toMap() => {
        'trace_chain': traces?.map((v) => v?.toMap()['trace']).toList(),
      };

  static TraceChain fromMap(Map attributes) {
    var chain = attributes['trace_chain'] as List;
    return TraceChain()
      ..traces = chain.map((v) => TraceInfo.fromMap({'trace': v})).toList();
  }
}

/// A text message to be sent to Rollbar.
class Message implements Body {
  String? body;

  @override
  List<TraceInfo> get traces => [];

  static Message? fromMap(Map attributes) {
    if (!attributes.containsKey('message')) {
      return null;
    }

    attributes = attributes['message'];

    return Message()..body = attributes['body'];
  }

  @override
  JsonMap toMap() => {
        'message': {
          'body': body,
        }
      };
}
