import '../../ext/collections.dart';

/// Contains all the error details except the stack trace.
class ExceptionInfo {
  String? clazz;
  String? message;
  String? description;

  ExceptionInfo();

  factory ExceptionInfo.fromMap(JsonMap attributes) => ExceptionInfo()
    ..clazz = attributes['class']
    ..message = attributes['message']
    ..description = attributes['description'];

  factory ExceptionInfo.from(dynamic error, String? description) {
    if (error is ExceptionInfo) {
      return error..description ??= description;
    }

    return ExceptionInfo()
      ..clazz = error.runtimeType.toString()
      ..message = error.toString()
      ..description = description;
  }

  JsonMap toMap() => {
        'class': clazz,
        'message': message,
        'description': description,
      }..removeWhere((k, v) => v == null);
}
