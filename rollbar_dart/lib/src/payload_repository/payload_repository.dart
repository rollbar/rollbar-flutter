import 'dart:async';
import 'dart:core';

import 'destination.dart';
import 'payload_record.dart';
import 'db_data_access.dart';

class PayloadRepository {
  final DbDataAccess _dataAccess;

  PayloadRepository(this._dataAccess);

  // Factory methods:
  ///////////////////

  static PayloadRepository create(bool persistent) {
    var dataAccess = DbDataAccess().initialize(asPersistent: persistent);
    dataAccess.deleteUnusedDestinations();
    return PayloadRepository(dataAccess);
  }

  static PayloadRepository createInMemory() {
    return create(false);
  }

  static PayloadRepository createPersistent() {
    return create(true);
  }

  // Entities manipulation methods:
  /////////////////////////////////

  Set<Destination> getDestinations() {
    return _dataAccess.selectAllDestinations();
  }

  int addDestination(Destination destination) {
    final int id = _dataAccess.insertDestination(destination);
    return id;
  }

  Set<PayloadRecord> getPayloadRecords() {
    return _dataAccess.selectAllPayloadRecords();
  }

  Set<PayloadRecord> getPayloadRecordsForDestination(Destination destination) {
    if (destination.id != null) {
      return _dataAccess.selectPayloadRecordsWithDestinationID(destination.id!);
    }
    return <PayloadRecord>{};
  }

  Set<PayloadRecord> getPayloadRecordsWithDestinationID(int destinationID) {
    return _dataAccess.selectPayloadRecordsWithDestinationID(destinationID);
  }

  // Async factory methods:
  /////////////////////////

  static Future<PayloadRepository> createAsync(bool persistent) async {
    return create(persistent);
  }

  static Future<PayloadRepository> createInMemoryAsync() async {
    return create(false);
  }

  static Future<PayloadRepository> createPersistentAsync() async {
    return create(true);
  }

  // Async entities manipulation methods:
  ///////////////////////////////////////

  Future<Set<Destination>> getDestinationsAsync() async {
    return getDestinations();
  }

  Future<int> addDestinationAsync(Destination destination) async {
    return addDestination(destination);
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
}
