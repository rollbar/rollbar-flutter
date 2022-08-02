import 'package:logging/logging.dart' show Logger, Level;
import 'package:rollbar_dart/rollbar.dart' show Rollbar, Config;

/// Command line application example using rollbar-dart.
void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) =>
      print('${record.level.name}: ${record.time}: ${record.message}'));

  // NOTE: Use your Rollbar Project access token:
  final config = Config(
    accessToken: 'YOUR-ROLLBAR-ACCESSTOKEN',
    package: 'rollbar_dart_example',
  );

  await Rollbar.run(config);

  for (var i = 10; i > 0; i--) {
    try {
      throw ArgumentError('$i: An error occurred in the dart example app');
    } catch (error, stackTrace) {
      Rollbar.error(error, stackTrace);
    }
  }

  await Future.delayed(Duration(seconds: 10));
}
