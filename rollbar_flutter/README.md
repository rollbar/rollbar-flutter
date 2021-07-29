# rollbar-flutter

[Flutter](https://flutter.dev/) notifier for reporting exceptions, errors and log messages to [Rollbar](https://rollbar.com).

## `rollbar-flutter` is currently in Beta. We are looking for beta-testers and feedback!

## Usage

A simple usage example:

```dart
import 'package:flutter/services.dart';
import 'package:rollbar_flutter/rollbar.dart';

Future<void> main() async {
  var config = (ConfigBuilder('<YOUR ROLLBAR TOKEN HERE>')
        ..environment = 'production'
        ..codeVersion = '1.0.0'
        ..handleUncaughtErrors = true)
      .build();

  await RollbarFlutter.run(config, (_rollbar) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  // Your application code here...
}
```

With this setup, `rollbar-flutter` will automatically catch and report any unhandled errors in your application.

You can also use the rollbar instance to explicitly report errors or messages to Rollbar:

```dart
import 'package:flutter/services.dart';
import 'package:rollbar_flutter/rollbar.dart';

Future<void> main() async {
  var config = (ConfigBuilder('<YOUR ROLLBAR TOKEN HERE>')
        ..environment = 'production'
        ..codeVersion = '1.0.0'
        ..handleUncaughtErrors = true)
      .build();

  await RollbarFlutter.run(config, (rollbar) async {
    await rollbar.infoMsg('Nothing out of the ordinary so far...');
  });
}
```

See the [`example` directory](./example/) for a complete example.

## Platform Support

* Android: Yes
* iOS: In Development
* Web: No
* Windows: No
* macOS: No
* Linux: No

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
