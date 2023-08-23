# rollbar-flutter

[Flutter](https://flutter.dev/) notifier for reporting exceptions, errors and log messages to [Rollbar](https://rollbar.com).

## Usage

A simple usage example:

```dart
import 'package:flutter/services.dart';
import 'package:rollbar_flutter/rollbar.dart';

Future<void> main() async {
  const config = Config(
    accessToken: 'YOUR-ROLLBAR-ACCESSTOKEN',
    package: 'rollbar_flutter_example',
  );

  await RollbarFlutter.run(config, () => runApp(const MyApp()));
}
```

With this setup, `rollbar-flutter` will automatically catch and report any unhandled errors in your application.

You can also explicitly report errors or messages to Rollbar:

```dart
await Rollbar.info('Nothing out of the ordinary so far...');
```

See the [`example` directory](./example/) for a complete example.

## Compatibility

- Flutter 3: version **3.0.0** and above

Logging version-specific issues, even outside of the supported versions, is welcome and they will be fixed whenever possible.

## Platform Support

- Android: Yes
- iOS: Yes
- Web: No
- Windows: No
- macOS: No
- Linux: No

Additional platforms will be prioritized based on feedback from users.

## Documentation

For complete usage instructions and configuration reference, see our [`rollbar-flutter` SDK docs](https://docs.rollbar.com/docs/flutter#flutter).

## Release History & Changelog

See our [Releases](https://github.com/rollbar/rollbar-flutter/releases) page for a list of all releases and changes.

## Help / Support

If you run into any issues, please email us at [support@rollbar.com](mailto:support@rollbar.com).

For bug reports, please open an issue on [GitHub](https://github.com/rollbar/rollbar-flutter/issues/new).

## License

`rollbar-flutter` is free software released under the MIT License. See [LICENSE](./LICENSE) for details.
