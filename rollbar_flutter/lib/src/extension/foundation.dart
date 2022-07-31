import 'package:flutter/foundation.dart';

extension TargetPlatformExtensions on TargetPlatform {
  bool get isAndroid => this == TargetPlatform.android;
  bool get isFuchsia => this == TargetPlatform.fuchsia;
  bool get isiOS => this == TargetPlatform.iOS;
  bool get ismacOS => this == TargetPlatform.macOS;
  bool get isLinux => this == TargetPlatform.linux;
  bool get isWindows => this == TargetPlatform.windows;
}
