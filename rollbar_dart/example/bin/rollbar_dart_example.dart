import 'package:rollbar_dart/rollbar.dart';

/// Command line application example using rollbar-dart.
void main() async {
  var config = (ConfigBuilder('<YOUR ROLLBAR TOKEN HERE>')
        ..environment = 'development'
        ..codeVersion = '0.1.0'
        ..handleUncaughtErrors = true)
      .build();

  var rollbar = Rollbar(config);

  try {
    throw ArgumentError('An error occurred in the dart example app');
  } catch (error, stackTrace) {
    await rollbar.error(error, stackTrace);
  }
}
