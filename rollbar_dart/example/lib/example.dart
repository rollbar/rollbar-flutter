import 'package:logging/logging.dart' show Logger, Level;
import 'package:rollbar_dart/rollbar.dart'
    show Rollbar, ConfigBuilder, RollbarInfrastructure;

/// Command line application example using rollbar-dart.
void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // NOTE: Use your Rollbar Project access token:
  final config = (ConfigBuilder('17965fa5041749b6bf7095a190001ded')
        ..environment = 'development'
        ..codeVersion = '0.3.0'
        ..package = 'rollbar_dart_example'
        ..persistPayloads = true
        ..handleUncaughtErrors = true)
      .build();

  await RollbarInfrastructure.instance.initialize(rollbarConfig: config);

  final rollbar = Rollbar(config);

  for (var i = 10; i > 0; i--) {
    try {
      throw ArgumentError('$i: An error occurred in the dart example app');
    } catch (error, stackTrace) {
      await rollbar.error(error, stackTrace);
    }
  }

  await Future.delayed(Duration(seconds: 10));
  await RollbarInfrastructure.instance.dispose();
}
