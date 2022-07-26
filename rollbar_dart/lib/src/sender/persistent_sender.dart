import 'dart:convert';
import 'dart:developer';

import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

import '../../rollbar.dart';

/// Persistent [Sender]. Default [Sender] implementation.
@immutable
class PersistentSender implements Sender {
  final Config config;

  const PersistentSender(this.config);

  @override
  Future<bool> send(JsonMap payload) async => sendString(jsonEncode(payload));

  @override
  Future<bool> sendString(String payload) async {
    try {
      Rollbar.process(
          record: Record(
              accessToken: config.accessToken,
              endpoint: config.endpoint,
              config: jsonEncode(config.toMap()),
              payload: payload));

      return true;
    } catch (error, stackTrace) {
      log('Error persisting payload: $error. Stack trace: $stackTrace');
      return false;
    }
  }
}
