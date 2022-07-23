import 'package:meta/meta.dart';

@sealed
class Environment {
  static const String mode = isDebug
      ? 'development'
      : isProfile
          ? 'profiling'
          : isRelease
              ? 'production'
              : 'unknown';

  static const bool isRelease = bool.fromEnvironment('dart.vm.product');
  static const bool isProfile = bool.fromEnvironment('dart.vm.profile');
  static const bool isDebug = !isRelease && !isProfile;
}
