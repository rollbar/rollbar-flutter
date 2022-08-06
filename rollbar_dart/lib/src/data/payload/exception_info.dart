import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

/// Contains all the error details except the stack trace.
@sealed
@immutable
class ExceptionInfo
    with EquatableSerializableMixin
    implements Equatable, Serializable {
  final String type;
  final String message;
  final String? description;

  const ExceptionInfo({
    required this.type,
    required this.message,
    this.description,
  });

  factory ExceptionInfo.fromMap(JsonMap map) => ExceptionInfo(
      type: map['class'],
      message: map['message'],
      description: map['description']);

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

  @override
  JsonMap toMap() => {
        'class': type,
        'message': message,
        'description': description,
      }.compact();
}
