import 'package:http/http.dart' as http;

enum HttpMethod { get, head, post, put, delete, connect, options, trace, patch }

enum HttpStatus { info, success, redirect, clientError, serverError }

typedef HttpHeaders = Map<String, String>;

extension HttpMethodName on HttpMethod {
  String get name => toString().split('.').last.toUpperCase();
}

extension HttpResponseExtension on http.Response {
  /// The HTTP status for this response derived from the status code.
  HttpStatus get status {
    if (statusCode >= 100 && statusCode < 200) {
      return HttpStatus.info;
    } else if (statusCode >= 200 && statusCode < 300) {
      return HttpStatus.success;
    } else if (statusCode >= 300 && statusCode < 400) {
      return HttpStatus.redirect;
    } else if (statusCode >= 400 && statusCode < 500) {
      return HttpStatus.clientError;
    } else if (statusCode >= 500 && statusCode < 600) {
      return HttpStatus.serverError;
    } else {
      throw StateError('http status code $statusCode is invalid.');
    }
  }
}
