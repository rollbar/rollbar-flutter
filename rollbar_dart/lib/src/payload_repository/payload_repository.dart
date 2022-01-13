import 'dart:async';
import 'dart:core';

import 'destination.dart';
import 'payload_record.dart';
import 'db_data_access.dart';

class PayloadRepository {
  final DbDataAccess _dataAccess;

  PayloadRepository(this._dataAccess);

  static Future<PayloadRepository> create(bool persistent) async {
    var dataAccess = DbDataAccess().initialize(asPersistent: persistent);
    return PayloadRepository(dataAccess);
  }

  static Future<PayloadRepository> createInMemory() async {
    return create(false);
  }

  static Future<PayloadRepository> createPersistent() async {
    return create(true);
  }

  Future<Set<Destination>> getDestinations() async {
    return _dataAccess.selectAllDestinations();
  }

  Future<int> addDestination(Destination destination) async {
    final int id = _dataAccess.insertDestination(destination);
    return id;
  }

  Future<Set<PayloadRecord>> getPayloadRecords() async {
    return _dataAccess.selectAllPayloadRecords();
  }

  Future<Set<PayloadRecord>> getPayloadRecordsForDestination(
      Destination destination) async {
    if (destination.id != null) {
      return _dataAccess.selectPayloadRecordsWithDestinationID(destination.id!);
    }
    return <PayloadRecord>{};
  }

  Future<Set<PayloadRecord>> getPayloadRecordsWithDestinationID(
      int destinationID) async {
    return _dataAccess.selectPayloadRecordsWithDestinationID(destinationID);
  }
}
