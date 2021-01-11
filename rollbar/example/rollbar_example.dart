import 'dart:convert';
import 'package:rollbar/rollbar.dart';

void main() async {
  var config = Config('<your_access_token_here>', 'production', '1.0.0');
  var rollbar = Rollbar(config);
  try {
    throw ArgumentError('error occurred in dart app');
  } catch (error, stackTrace) {
    final response = await rollbar.error(error, stackTrace);
    print(json.decode(response.body));
  }
}
