import 'package:flutter/services.dart';
import 'package:rollbar_dart/rollbar.dart';

import '../method_channel.dart';
import 'hook.dart';

class NativeHook implements Hook {
  static const _platform = MethodChannel('com.rollbar.flutter');

  @override
  Future<void> install(final Config config) async {
    await _platform.initialize(config: config);
  }

  @override
  Future<void> uninstall() async {
    await _platform.close();
  }
}
