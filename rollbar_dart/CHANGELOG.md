# Changelog

## 1.1.0
- A more robust Persistent HTTP Sender error handling strategy allows for better outcomes and recovery in case of server and client errors.
- The Rollbar SDK will now produce more informative logs when dealing with network, HTTP client and/or server errors.
- HTTP client has been modularized in order to support mocking and noop clients.
- Fixed a bug where persisted payloads that couldn't be sent due to an incorrect endpoint or access token in the Config, would never be sent again when corrected.

## 1.0.0

- New feature: Person tracking
  - Associate reports to your currently logged in User.
  - Users may be set freely, but don't persist in-between application runs.
  - Occurrences and items reported on Rollbar will have a User associated with them, allowing to organize and track issues pertaining to specific users.
- Various bug fixes and performance improvements.

## 0.4.0-beta

- New feature: Telemetry.
  - See all the breadcrumbs leading up to an error on Rollbar.
  - Gather extra data silently by "dropping breadcrumbs" with information about UI navigation, app events, connectivity events, and more.
  - Telemetry is only sent to Rollbar at the on-set of an occurrence (eg. an exception)
- Big improvements to multithreading correctness, performance and security: Now the _entire_ Rollbar process flow is performed in a memory-isolated thread guaranteeing the library will never take control of your main-thread where your UX/app logic and UI rendering takes place.
- We've set Dart 2.17.0 as the minimum required Dart version, we decided that the new features introduced to the language were too good to pass, including features that will allow us to provide not only the best possible library, but a modern API for developers.
- Internals have been restructured with Modularity over ORM in mind. This architecture strategy that comes from the Functional world, allows us to build a highly composable internal architecture with minimal inter-depdendence.
  - Building parts for our library becomes more like building Legos rather than intertwined object relationships.

## 0.3.0-beta

- Simplified API.
- Persistent payloads.
- More efficient usage of multithreading.
- Fully type-safe, null-safe and endowed with immutability.
- Fixed null-related crashes.
- Fixed console logging disappearing when letting Rollbar catch uncaught errors.
- Many more bug fixes.

## 0.2.0-beta

- Added null-safety.

## 0.1.0-beta

- Initial version of rollbar-dart.
