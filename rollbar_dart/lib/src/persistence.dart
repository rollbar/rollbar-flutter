import 'dart:developer';

import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';
import 'package:sqlite3/sqlite3.dart';

import 'config.dart';

/// A mixin that provides a ready-to-use lazily initialized [TableSet] that
/// leverages a shared static sqlite3 [Database].
@immutable
@internal
mixin Persistence<Record extends Persistable<UUID>> implements Configurable {
  static Database? _database;

  late final TableSet<Record> records = TableSet(database: () {
    try {
      _database ??= config.persistenceLifetime > Duration.zero
          ? sqlite3.open('${config.persistencePath}/rollbar.db')
          : sqlite3.openInMemory();
    } on SqliteException catch (error, stackTrace) {
      log('Exception opening sqlite3 database to persist for ${config.persistenceLifetime}',
          time: DateTime.now(),
          level: Level.warning.value,
          name: runtimeType.toString(),
          error: error,
          stackTrace: stackTrace);
    } finally {
      _database ??= sqlite3.openInMemory();
    }

    return _database as Database;
  }());

  bool didExpire(Record record) =>
      record.timestamp < DateTime.now().toUtc() - config.persistenceLifetime;
}
