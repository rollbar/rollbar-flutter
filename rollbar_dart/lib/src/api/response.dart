/// Represents the response from the Rollbar API.
class Response {
  int? err;
  String? message;
  Result? result;

  bool isError() {
    return err != null && err != 0;
  }
}

class Result {
  String? uuid;
}
