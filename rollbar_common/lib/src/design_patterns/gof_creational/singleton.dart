class Singleton {
  static Singleton? _instance;

  Singleton._internal() {
    _instance = this;
  }

  // Returns reference to the Singleton object.
  // Use this factory method/constructor instead of the single instance getter.
  factory Singleton() => _instance ?? Singleton._internal();

  // static get instance {
  //   _instance ??= Singleton._internal();

  //   return _instance;
  // }
}
