// The `import_duplicated_library_named` check from Flutter 1.x doesn't consider
// aliases, so importing both `rollbar_flutter/rollbar.dart` and
// `rollbar_dart/rollbar_dart` fails the lint check no matter which aliases we
// give them.
// This is not a problem on Flutter 2, but we want to run the analyzer under
// Flutter 1 as well, hence this workaround.

export 'package:rollbar_dart/rollbar.dart';
