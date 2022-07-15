import 'package:meta/meta.dart';

import '../../ext/collections.dart';
import 'data.dart';

/// Represents the payload to be sent to Rollbar. A successfully constructed
/// Payload matches Rollbar's spec, and can be POSTed to the correct endpoint
/// when serialized as JSON.
@sealed
@immutable
class Payload {
  final String accessToken;
  final Data data;

  const Payload(this.accessToken, this.data);

  JsonMap toMap() => {
        'access_token': accessToken,
        'data': data.toMap(),
      };
}
