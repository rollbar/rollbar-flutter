/// Contains all the error details except the stack trace.
class ExceptionInfo {
  String clazz;
  String message;
  String description;

  Map<String, dynamic> toJson() {
    var result = {'class': clazz, 'message': message};
    if (description != null) {
      result['description'] = description;
    }
    return result;
  }

  static ExceptionInfo fromMap(Map<String, dynamic> attributes) {
    var result = ExceptionInfo();
    if (attributes.containsKey('class')) {
      result.clazz = attributes['class'];
    }
    if (attributes.containsKey('message')) {
      result.message = attributes['message'];
    }
    if (attributes.containsKey('description')) {
      result.description = attributes['description'];
    }
    return result;
  }
}
