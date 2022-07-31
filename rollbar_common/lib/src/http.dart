enum HttpMethod { get, head, post, put, delete, connect, options, trace, patch }

extension HttpMethodName on HttpMethod {
  String get name => toString().split('.').last.toUpperCase();
}
