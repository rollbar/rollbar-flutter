# Changelog

## 1.3.1

- Fixed an issue with Flutter bindings being initialized in a different zone than the one actually used by the app.

## 1.3.0

- Updated the Rollbar Dart SDK to 1.2.0 which includes fixes to two bugs reported by the community, brought by a general refactor of the event processing mechanism.
- The example was updated to reflect the API usages that where triggering the issues.

## 1.2.0

- Updated internal Rollbar Apple SDK from 1.x to 2.3.4.
- Using the newest version of the Rollbar Apple SDK will improve the ability for users to catch _native_ errors and fix them while using the Flutter SDK.
- Fixed compilation issue when running on iOS Simulator with Apple Silicon `arm64`.

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
- We now capture extended Flutter exception and error details which contain extra data and breadcrumbs about UI-related issues.
- Various bug fixes and performance improvements.

## 0.4.0-beta

- Updated Example to showcase the new Telemetry feature.
- Fixed an issue where occurrences weren't being persisted by sqlite3, therefore Rollbar reports could be lost after a crash.

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

- Initial version of rollbar-flutter.
