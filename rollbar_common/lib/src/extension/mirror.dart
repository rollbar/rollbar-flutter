import 'object.dart';

extension SymbolExtensions on Symbol {
  /// The symbolic name this symbol represents.
  ///
  /// '''dart
  /// (#Symbol.name).name // returns 'name'
  /// (#List.first).name // returns 'List.first'
  /// '''
  String get name {
    final symbol = toString();
    return RegExp(r'''(?<=\"|\').+?(?=\"|\')''')
        .firstMatch(symbol)
        .map((match) => symbol.substring(match.start, match.end))
        .or('');
  }
}
