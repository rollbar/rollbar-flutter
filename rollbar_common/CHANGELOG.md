# Changelog

## 1.1.1

- Updated http library to '>=0.13.0 <2.0.0'
- Updated uuid library to '^4.1.0'
- Updated sdk constraint to '>=2.17.0 <4.0.0'
- Fixed warnings about the value of 'identity' not being used.

## 1.1.0

- Added Result<T, E>, a class that represents either a `Success` value _or_ a `Failure` with an `Error`.
- Timestamps are now defined by the `Persistable` class.
- Added more extensions.

## 1.0.0

- Added `mapFirst` and `mapSecond` to `Tuple2` to map over a pair's values.
- `Persistable` now defines the `Comparable` instead of using `dynamic`.
- Hid `*Record` type-safe key value paths.

## 0.4.0-beta

- New generic, functional `TableSet` collection that abstracts SQL declarations by allowing the management of sqlite3 tables as standard Dart `Set` collections over `Serializable` sealed immutable classes.
- Generic `zip` function for collections that allow to iterate two collections side by side.
- New functional language extensions on various Dart types and collections:
  - `Iterable`, `Map`, `DateTime`, `Mirror`, `Random`, `String`, `Object`, and more.
- The `ConnectivityMonitor` has been removed.

## 0.3.1-beta

- New language extensions on basic Dart types and functions.
- Added a Tuple2 sealed and immutable data class.

## 0.2.0-beta

- Initial version.
