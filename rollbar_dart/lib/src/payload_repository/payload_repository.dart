import 'dart:core';

import 'package:sqlite3/sqlite3.dart';

import 'destination.dart';
import 'payload_record.dart';
import 'db_data_access.dart';

class PayloadRepository {
  final DbDataAccess _dataAccess;

  PayloadRepository({required bool persistent})
      : _dataAccess = DbDataAccess().initialize(asPersistent: persistent);

  // Factory methods:
  ///////////////////

  static PayloadRepository createInMemory() =>
      PayloadRepository(persistent: false);

  static PayloadRepository createPersistent() =>
      PayloadRepository(persistent: true);

  // Entities manipulation methods:
  /////////////////////////////////

  Set<Destination> get destinations =>
      _dataAccess.selectAllDestinations().map(_createDestination).toSet();

  int addDestination(Destination destination) {
    return _dataAccess.insertDestination(destination);
  }

  void removeUnusedDestinations() {
    _dataAccess.deleteUnusedDestinations();
  }

  Set<PayloadRecord> getPayloadRecords() {
    final destinations = {for (final d in this.destinations) d.id!: d};
    return _dataAccess
        .selectAllPayloadRecords()
        .map((row) => _createPayloadRecord(
            row, destinations[row[PayloadRecordsTable.colDestinationKey]]!))
        .toSet();
  }

  Set<PayloadRecord> getPayloadRecordsForDestination(Destination destination) {
    final Set<PayloadRecord> records = <PayloadRecord>{};
    if (destination.id == null) {
      _dataAccess.insertDestination(destination);
    }
    for (final row
        in _dataAccess.selectPayloadRecordsWithDestinationID(destination.id!)) {
      records.add(_createPayloadRecord(row, destination));
    }
    return records;
  }

  Set<PayloadRecord> getPayloadRecordsWithDestinationID(int destinationID) {
    final Set<PayloadRecord> records = <PayloadRecord>{};
    final destinationRow = _dataAccess.selectDestination(destinationID);
    if (destinationRow == null) {
      return records;
    }

    var destination = _createDestination(destinationRow);
    return getPayloadRecordsForDestination(destination);
  }

  int addPayloadRecord(PayloadRecord payloadRecord) {
    if (payloadRecord.destination.id == null) {
      int? destinationID = _dataAccess.findDestinationID(
          endpoint: payloadRecord.destination.endpoint,
          accessToken: payloadRecord.destination.accessToken);
      if (destinationID == null) {
        _dataAccess.insertDestination(payloadRecord.destination);
      } else {
        // ignore: invalid_use_of_protected_member
        payloadRecord.destination.assignID(destinationID);
      }
    }
    return _dataAccess.insertPayloadRecord(payloadRecord);
  }

  void removePayloadRecord(PayloadRecord record) {
    _dataAccess.deletePayloadRecord(record);
  }

  void removePayloadRecordWithID(int recordID) {
    _dataAccess.deleteDestinationWithID(recordID);
  }

  void removePayloadRecordsOlderThan(DateTime utcExpirationTime) {
    _dataAccess.deletePayloadRecordsOlderThan(utcExpirationTime);
  }

  // Async entities manipulation methods:
  ///////////////////////////////////////

  Future<Set<Destination>> getDestinationsAsync() async {
    return destinations;
  }

  Future<int> addDestinationAsync(Destination destination) async {
    return addDestination(destination);
  }

  Future<void> removeUnusedDestinationsAsync() async {
    removeUnusedDestinations();
  }

  Future<Set<PayloadRecord>> getPayloadRecordsAsync() async {
    return getPayloadRecords();
  }

  Future<Set<PayloadRecord>> getPayloadRecordsForDestinationAsync(
      Destination destination) async {
    return getPayloadRecordsForDestination(destination);
  }

  Future<Set<PayloadRecord>> getPayloadRecordsWithDestinationIDAsync(
      int destinationID) async {
    return getPayloadRecordsWithDestinationID(destinationID);
  }

  Future<int> addPayloadRecordAsync(PayloadRecord payloadRecord) async {
    return addPayloadRecord(payloadRecord);
  }

  Future<void> removePayloadRecordAsync(PayloadRecord record) async {
    removePayloadRecord(record);
  }

  Future<void> removePayloadRecordWithIDAsync(int recordID) async {
    removePayloadRecordWithID(recordID);
  }

  Future<void> removePayloadRecordsOlderThanAsync(
      DateTime utcExpirationTime) async {
    removePayloadRecordsOlderThan(utcExpirationTime);
  }

  // Private methods:
  ///////////////////

  static Destination _createDestination(Row dataRow) {
    return Destination(
        id: dataRow[DestinationsTable.colId],
        endpoint: dataRow[DestinationsTable.colEndpoint],
        accessToken: dataRow[DestinationsTable.colAccessToken]);
  }

  static PayloadRecord _createPayloadRecord(
      Row dataRow, Destination destination) {
    return PayloadRecord(
        id: dataRow[PayloadRecordsTable.colId],
        timestamp: DateTime.fromMillisecondsSinceEpoch(
            (dataRow[PayloadRecordsTable.colCreatedAt] * 1000).toInt()),
        configJson: dataRow[PayloadRecordsTable.colConfigJson],
        payloadJson: dataRow[PayloadRecordsTable.colPayloadJson],
        destination: destination);
  }
}
