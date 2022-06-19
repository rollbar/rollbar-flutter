import 'exception_info.dart';
import 'frame.dart';

/// Container class with the error or message to be sent to Rollbar.
abstract class Body {
  Map<String, dynamic> toJson();
  List<TraceInfo?>? getTraces();

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
}

/// An individual error with its corresponding stack trace if available.
class TraceInfo implements Body {
  late List<Frame> frames;
  ExceptionInfo? exception;
  String? rawTrace;

  TraceInfo() {
    frames = [];
  }

  @override
  List<TraceInfo> getTraces() {
    return [this];
  }

  @override
  Map<String, dynamic> toJson() {
    var traceInfo = <String, dynamic>{
      'trace': <String, dynamic>{
        'frames': frames.map((f) => f.toJson()).toList(),
      }
    };

    if (exception != null) {
      traceInfo['trace']['exception'] = exception!.toJson();
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
  List<TraceInfo?>? traces;

  @override
  Map<String, dynamic> toJson() {
    return {'trace_chain': traces!.map((v) => v!.toJson()['trace']).toList()};
  }

  static TraceChain fromMap(Map attributes) {
    var chain = attributes['trace_chain'] as List;
    return TraceChain()
      ..traces = chain.map((v) => TraceInfo.fromMap({'trace': v})).toList();
  }

  @override
  List<TraceInfo?>? getTraces() => traces;
}

/// A text message to be sent to Rollbar.
class Message implements Body {
  String? body;

  @override
  List<TraceInfo> getTraces() => [];

  static Message? fromMap(Map attributes) {
    if (!attributes.containsKey('message')) {
      return null;
    }

    attributes = attributes['message'];

    return Message()..body = attributes['body'];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'message': {'body': body}
    };
  }
}
