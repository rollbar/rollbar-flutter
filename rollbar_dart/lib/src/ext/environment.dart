import 'package:meta/meta.dart';

@sealed
@internal
class Environment {
  @internal
  static const String mode = isDebug
      ? 'development'
      : isProfile
          ? 'profiling'
          : isRelease
              ? 'production'
              : 'unknown';

  @internal
  static const bool isRelease = bool.fromEnvironment('dart.vm.product');

  @internal
  static const bool isProfile = bool.fromEnvironment('dart.vm.profile');

  @internal
  static const bool isDebug = !isRelease && !isProfile;
}
