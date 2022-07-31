import 'dart:math';

extension RandomExtensions on Random {
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  String nextString(int length) {
    int nextChar(_) => _chars.codeUnitAt(nextInt(_chars.length));
    return String.fromCharCodes(Iterable.generate(length, nextChar));
  }
}
