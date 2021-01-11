A Rollbar SDK for Dart developers.

## Usage

A simple usage example:

```dart
import 'package:rollbar/rollbar.dart';

void main() {
  var config = Config('<your_access_token_here>', 'production', '1.0.0');
  var rollbar = Rollbar(config);
  try {
    throw ArgumentError('error occurred in dart app');
  } catch (error, stackTrace) {
    rollbar.error(error, stackTrace);
  }
}
```