/// Contains all the error details except the stack trace.
class ExceptionInfo {
  String? clazz;
  String? message;
  String? description;

  Map<String, dynamic> toJson() {
    final result = {'class': clazz, 'message': message};
    if (description != null) {
      result['description'] = description;
    }
    return result;
  }

  ExceptionInfo();

  factory ExceptionInfo.fromMap(Map<String, dynamic> attributes) =>
      ExceptionInfo()
        ..clazz = attributes['class']
        ..message = attributes['message']
        ..description = attributes['description'];
}
