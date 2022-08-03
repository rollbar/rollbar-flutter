import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

import 'data/payload/reading.dart';
import 'persistence.dart';
import 'config.dart';

@sealed
@immutable
@internal
class Telemetry with Persistence<ReadingRecord> implements Configurable {
  @override
  final Config config;

  Telemetry(this.config);

  bool register(Reading reading) {
    final expiration = DateTime.now().toUtc() - config.persistenceLifetime;
    records.removeWhere((record) => record.timestamp < expiration);

    return records.add(
      ReadingRecord(reading: jsonEncode(reading.toMap())),
    );
  }

  List<Reading> snapshot() => records
      .sorted(by: #ReadingRecord.timestamp)
      .map((record) => jsonDecode(record.reading) as JsonMap)
      .map(Reading.fromMap)
      .toList();
}
