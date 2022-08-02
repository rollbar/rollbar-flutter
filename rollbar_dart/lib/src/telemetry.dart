import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

import 'data/payload/reading.dart';
import 'config.dart';

@sealed
@immutable
class Telemetry {
  final TableSet<ReadingRecord> readings;

  Telemetry(Config config)
      : readings = TableSet(isPersistent: config.persistPayloads);

  bool register(Reading reading) => readings.add(
        ReadingRecord(reading: jsonEncode(reading.toMap())),
      );

  Iterable<Reading> snapshot() => readings
      .sorted(by: #ReadingRecord.timestamp)
      .map((record) => jsonDecode(record.reading) as JsonMap)
      .map(Reading.fromMap);
}
