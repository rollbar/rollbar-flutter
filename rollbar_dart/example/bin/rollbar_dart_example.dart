import 'package:logging/logging.dart' as diag;
import 'package:rollbar_dart/rollbar.dart';

/// Command line application example using rollbar-dart.
void main() async {
  diag.Logger.root.level = diag.Level.ALL;
  diag.Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

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
  } finally {
    await Future.delayed(Duration(seconds: 5));
    await RollbarInfrastructure.instance.dispose();
  }
}
