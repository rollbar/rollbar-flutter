/// The level of an occurrence.
enum Level { debug, info, warning, error, critical }

extension LevelExtension on Level {
  // The 'foundation' library, which contains `describeEnum`, is part of flutter,
  // so we don't want to add it as a dependency in rollbar-dart.
  String get name {
    switch (this) {
      case Level.debug:
        return 'debug';
      case Level.info:
        return 'info';
      case Level.warning:
        return 'warning';
      case Level.error:
        return 'error';
      case Level.critical:
        return 'critical';
    }
    return null;
  }
}
