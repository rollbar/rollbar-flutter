import 'package:meta/meta.dart';
import '../../ext/collections.dart';

/// Contains all the error details except the stack trace.
@sealed
class ExceptionInfo {
  final String type;
  String message;
  final String? description;

  ExceptionInfo({
    required this.type,
    required this.message,
    this.description,
  });

  factory ExceptionInfo.fromMap(JsonMap attributes) => ExceptionInfo(
      type: attributes.type,
      message: attributes.message,
      description: attributes.description);

  factory ExceptionInfo.from(dynamic error, String? description) {
    if (error is ExceptionInfo) {
      return error.copyWith(description: error.description ?? description);
    }

    return ExceptionInfo(
        type: error.runtimeType.toString(),
        message: error.toString(),
        description: description);
  }

  ExceptionInfo copyWith({
    String? type,
    String? message,
    String? description,
  }) =>
      ExceptionInfo(
          type: type ?? this.type,
          message: message ?? this.message,
          description: description ?? this.description);

  @override
  String toString() =>
      'ExceptionInfo(type: $type, message: $message, description: $description)';

  JsonMap toMap() => {
        'class': type,
        'message': message,
        'description': description,
      }..compact();
}

extension _Attributes on JsonMap {
  String get type {
    assert(containsKey('class'));
    return this['class'];
  }

  String get message {
    assert(containsKey('message'));
    return this['message'];
  }

  String? get description => this['description'];
}
