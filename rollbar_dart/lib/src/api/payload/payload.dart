import 'data.dart';

/// Represents the payload to be sent to Rollbar. A successfully constructed Payload matches Rollbar's
/// spec, and can be POSTed to the correct endpoint when serialized as JSON.
class Payload {
  String accessToken;
  Data data;

  Map<String, dynamic> toJson() {
    return {'access_token': accessToken, 'data': data.toJson()};
  }
}
