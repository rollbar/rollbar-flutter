# Changelog

## 1.3.2

- Updated http library to '>=0.13.0 <2.0.0'
- Updated sdk constraint to '>=2.17.0 <4.0.0'
- Fixed usage of unsafe_html which was removed in Dart 3.7.0.

## 1.3.1

- Fixed breadcrumbs not being processed in the right order in obfuscated builds.

## 1.3.0

- The log, debug, info, warn, error and critical methods in `Rollbar` now accept any type of object including `Error`, `Exception` and `String`. Dart objects that specialize `toString()` can be also passed and they'll be converted into their string representations.

## 1.2.0

- Fixed two issues reported by the community:
  - #91 Unsetting an user causes invalid argument exception, thanks to @rfuerst87 for reporting!
  - #93 rollbar_flutter: Rollbar interface methods are overridden based on type of error object thanks to @TRemigi for reporting!
- The way we process event notifications has been refactored. This refactor addresses multiple deficiencies with how we transfer information from our front-end API to our internal Notifier process. This refactor solves multiple bugs, and presents a scalable mechanism to add new functionality in a composable way with the least amount of changes due to a very modularized scheme.
  - The Notifier used to represent a sandboxed/isolated boundary between the SDK's innards and its API. Now the Notifier is just another switchable self-contained module just like the Transformer, Sender and Marshaller.
  - A new Sandbox module that represents the aforementioned isolated boundary which offers two flavors: async useful for unit testing, and isolated which leverages Dart's Isolates.
  - We keep the same level of security by sandboxing our memory, and full thread-enabled concurrency.
  - This helps remove business logic from the Notifier, which used to handle both the process pipeline and the isolation.
  - The way the API forwards messages to the Notifier is through Event instances, which is a type-safe way of encoding action and the data associated with such action. This event is dispatched to the Sandbox and the Sandbox sends it to the Isolate stream, and then it's given to the Notifier.
  - The Notifier encodes the pipeline that processes these Events. There are two types of Events:
    - Events that modify context (the SDK's state): In this case, the Notifier acts as a simple Reducer that modifies its internal state given the Event's data.
    - Events that forward data to Rollbar's API: In this case, the event is put through the Marshalling pipeline, the data is transformed if necessary, persisted and then sent.
  - Wrangler has been renamed to Marshaller.

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
