/// Contains the information of a single frame in a stack trace.
class Frame {
  int? colno;
  int? lineno;
  String? method;
  String? filename;
  String? className;

  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{};
    if (colno != null) {
      result['colno'] = colno;
    }
    if (lineno != null) {
      result['lineno'] = lineno;
    }
    if (method != null) {
      result['method'] = method;
    }
    if (filename != null) {
      result['filename'] = filename;
    }
    if (className != null) {
      result['class_name'] = className;
    }
    return result;
  }

  static Frame fromMap(Map attributes) {
    var result = Frame();
    if (attributes.containsKey('colno')) {
      result.colno = attributes['colno'] as int?;
    }
    if (attributes.containsKey('lineno')) {
      result.lineno = attributes['lineno'] as int?;
    }
    if (attributes.containsKey('method')) {
      result.method = attributes['method'];
    }
    if (attributes.containsKey('filename')) {
      result.filename = attributes['filename'];
    }
    if (attributes.containsKey('class_name')) {
      result.className = attributes['class_name'];
    }
    return result;
  }
}
