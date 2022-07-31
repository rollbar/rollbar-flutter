import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

/// Contains all the error details except the stack trace.
@sealed
@immutable
class ExceptionInfo {
  final String type;
  final String message;
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
      }.compact();
}

extension _Attributes on JsonMap {
  String get type => this['class'];
  String get message => this['message'];
  String? get description => this['description'];
}
