import 'dart:core';

import 'package:meta/meta.dart';
import 'package:sqlite3/sqlite3.dart';

import '../ext/object.dart';
import '../ext/database.dart';
import '../ext/identifiable.dart';

import 'payload_record.dart';
import 'payload_record_table.dart';

extension _PayloadRecord on PayloadRecord {
  static PayloadRecord from(Row row) => PayloadRecord(
      id: UUID.fromList(row.id),
      timestamp:
          DateTime.fromMillisecondsSinceEpoch((row.timestamp * 1000).toInt()),
      accessToken: row.accessToken,
      endpoint: row.endpoint,
      configJson: row.config,
      payloadJson: row.payload);
}

@sealed
@immutable
class PayloadRepository {
  final Database databse;

  PayloadRepository({required bool persistent})
      : databse = persistent
            ? sqlite3.open('rollbar_payloads.db')
            : sqlite3.openInMemory() {
    databse.execute(SQL.createPayloadRecordsTable);
  }
}

extension PayloadRecords on PayloadRepository {
  PayloadRecord? payloadRecord({required UUID id}) => databse
      .select(SQL.selectPayloadRecord, [id.toBytes()])
      .singleRow
      .map(_PayloadRecord.from);

  Set<PayloadRecord> get payloadRecords => databse
      .select(SQL.selectAllPayloadRecords)
      .map(_PayloadRecord.from)
      .toSet();

  // Set<PayloadRecord> payloadRecordsForDestination(Destination destination) =>
  //     databse
  //         .select(SQL.selectPayloadRecordsWithDestinationID,
  //             [destination.id.toBytes()])
  //         .map((row) => _PayloadRecord.from(row, destination))
  //         .toSet();

  // Set<PayloadRecord> getPayloadRecordsWithDestinationID(UUID id) =>
  //     destination(id: id).map(payloadRecordsForDestination) ?? {};

  void addPayloadRecord(PayloadRecord payloadRecord) =>
      databse.execute(SQL.insertPayloadRecord, [
        payloadRecord.id.toBytes(),
        payloadRecord.accessToken,
        payloadRecord.endpoint,
        payloadRecord.configJson,
        payloadRecord.payloadJson,
        payloadRecord.timestamp.millisecondsSinceEpoch / 1000
      ]);

  // void removePayloadRecord(PayloadRecord record) =>
  //     removePayloadRecordWithID(record.id);

  void removePayloadRecord({required UUID id}) => databse.execute(
        SQL.deletePayloadRecord,
        [id.toBytes()],
      );

  void removePayloadRecordsOlderThan(DateTime utcExpirationTime) =>
      databse.execute(SQL.deletePayloadRecordsOlderThan,
          [(utcExpirationTime.millisecondsSinceEpoch / 1000)]);
}
