# rollbar-dart

[Dart](https://dart.dev/) notifier for reporting exceptions, errors and log messages to [Rollbar](https://rollbar.com).

This is a Dart-only implementation providing core notifier features. If you're building a [Flutter](https://flutter.dev/) application you should use [`rollbar-flutter`](../rollbar_flutter/README.md) instead, which adds Flutter-specific features to the core functionality of this library.

## `rollbar-dart` is currently in Beta. We are looking for beta-testers and feedback!

## Usage

A simple usage example:

```dart
import 'package:rollbar_dart/rollbar.dart';

void main() async {
  var config = (ConfigBuilder('<YOUR ROLLBAR TOKEN HERE>')
        ..environment = 'production'
        ..codeVersion = '1.0.0')
      .build();

  var rollbar = Rollbar(config);

  try {
    throw ArgumentError('An error occurred in the dart example app.');
  } catch (error, stackTrace) {
    await rollbar.error(error, stackTrace);
  }
}
```

See the [`example` directory](./example/) for a complete example.

## Documentation

For complete usage instructions and configuration reference, see our [`rollbar-dart` SDK docs](https://docs.rollbar.com/docs/flutter#dart).

## Release History & Changelog

See our [Releases](https://github.com/rollbar/rollbar-flutter/releases) page for a list of all releases and changes.

## Help / Support

If you run into any issues, please email us at [support@rollbar.com](mailto:support@rollbar.com).

For bug reports, please open an issue on [GitHub](https://github.com/rollbar/rollbar-flutter/issues/new).

## License

`rollbar-dart` is free software released under the MIT License. See [LICENSE](./LICENSE) for details.
