import 'package:rollbar_dart/rollbar.dart';

/// Command line application example using rollbar-dart.
void main() async {
  var config = (ConfigBuilder('17965fa5041749b6bf7095a190001ded')
        ..environment = 'development'
        ..codeVersion = '0.1.0'
        ..package = 'rollbar_dart_example'
        ..persistPayloads = true
        ..handleUncaughtErrors = true)
      .build();

  await RollbarInfrastructure.instance.initialize(rollbarConfig: config);

  var rollbar = Rollbar(config);

  try {
    throw ArgumentError('An error occurred in the dart example app');
  } catch (error, stackTrace) {
    await rollbar.error(error, stackTrace);
    RollbarInfrastructure.instance.dispose();
  }
}
