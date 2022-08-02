import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

import 'data/payload/reading.dart';
import 'persistence.dart';
import 'config.dart';

@sealed
@immutable
class Telemetry with Persistence<ReadingRecord> implements Configurable {
  @override
  final Config config;

  Telemetry(this.config);

  bool register(Reading reading) => records.add(
        ReadingRecord(reading: jsonEncode(reading.toMap())),
      );

  List<Reading> snapshot() => records
      .sorted(by: #ReadingRecord.timestamp)
      .map((record) => jsonDecode(record.reading) as JsonMap)
      .map(Reading.fromMap)
      .toList();
}
