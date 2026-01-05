# Repository Guidelines

This monorepo hosts Rollbar SDKs for Dart and Flutter. Use the package-level READMEs for usage examples, and follow the guidelines below when contributing.

## Project Structure & Module Organization

- `rollbar_common/`: shared Dart core (models, serialization, extensions) used by both SDKs; tests live in `rollbar_common/test`.
- `rollbar_dart/`: pure Dart notifier package with examples in `rollbar_dart/example` and tests in `rollbar_dart/test`.
- `rollbar_flutter/`: Flutter plugin and platform integration; Dart sources in `rollbar_flutter/lib`, native code in `rollbar_flutter/android` and `rollbar_flutter/ios`, tests in `rollbar_flutter/test`, and a sample app in `rollbar_flutter/example`.
- `build_tools/`: scripts for linting, tests, builds, and publishing.

## Build, Test, and Development Commands

- `./build_tools/check.sh`: runs the standard CI-style pipeline across packages (pub get, `flutter test`, `flutter analyze`, `pana`, Gradle checks, and example builds).
- `./build_tools/build.sh -d rollbar_dart test`: run a single task in one package (tasks include `pub-get`, `test`, `analyze`, `pana`, `gradle-check`, `example-android`, `example-ios`).
- `./build_tools/clean.sh`: `flutter clean` for all packages.
- `cd rollbar_flutter/example && flutter run`: run the Flutter example app locally.

## Coding Style & Naming Conventions

- Dart code follows standard formatting (2-space indent) and analyzer rules from `analysis_options.yaml` in each package.
- Lints include `prefer_single_quotes`, `always_declare_return_types`, and `unawaited_futures` (plus `sort_child_properties_last` in `rollbar_dart`).
- Use Dart naming conventions: `UpperCamelCase` for types, `lowerCamelCase` for members, `snake_case` for files.

## Testing Guidelines

- Tests are organized under each package’s `test/` directory and run via `flutter test` from that package root.
- Android unit tests live under `rollbar_flutter/android/src/test`.
- Add or update tests for new behavior; there is no explicit coverage gate, but regression tests are expected.

## Commit & Pull Request Guidelines

- Commit messages are short and imperative; optional type/scope prefixes are common (e.g., `feat: ...`, `fix(android): ...`, `doc: ...`).
- Before opening a PR, run `./build_tools/check.sh` and note results in the PR description.
- Link relevant issues and describe platform-specific changes (Dart vs. Flutter, Android vs. iOS) clearly.

## Security & Configuration Tips

- Never commit real Rollbar access tokens; use placeholders like `YOUR-ROLLBAR-ACCESSTOKEN` in examples and tests.
