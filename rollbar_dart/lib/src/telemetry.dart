import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

import 'data/payload/reading.dart';
import 'config.dart';

@sealed
@immutable
class Telemetry {
  final Config _config;
  final TableSet<ReadingRecord> readings;

  Telemetry(this._config)
      : readings = TableSet(isPersistent: _config.persistPayloads);

  bool register(Reading reading) => readings.add(
        ReadingRecord(reading: jsonEncode(reading.toMap())),
      );
}
