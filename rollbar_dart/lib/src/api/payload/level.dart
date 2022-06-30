/// The level of an occurrence.
enum Level { debug, info, warning, error, critical }

extension LevelExtension on Level {
  String get name => toString().split('.').last;
}
