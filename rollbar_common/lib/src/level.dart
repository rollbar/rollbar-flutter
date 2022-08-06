/// The level of an occurrence.
enum Level {
  debug(500), // Level.FINE
  info(800), // Level.INFO
  warning(900), // Level.WARNING
  error(1000), // Level.SEVERE
  critical(1200); // Level.SHOUT

  const Level(this.value);

  final int value;
}
