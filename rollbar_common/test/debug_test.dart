import 'dart:core';
import 'package:test/test.dart';
import 'package:rollbar_common/src/debug.dart';

class OtherClass with DebugStringRepresentation {
  final other = 'other_value';
}

class SomeClass with DebugStringRepresentation {
  static const scnumber = 1234;
  static final sfnumber = 4321;
  static var svnumber = 5678;

  final fnumber = 8765;
  final object = OtherClass();
  var vnumber = 7890;
  var string = 'some_string';

  // ignore: unused_field
  final _private = 'some_private_var';

  // ignore: prefer_function_declarations_over_variables
  final closure = (String s) {};

  SomeClass();

  static void f() {}
  void g() {}
}

void main() {
  group('Debug Extensions', () {
    test('Debug string representation', () async {
      expect(
          '${SomeClass()}',
          'SomeClass('
              'scnumber: 1234, '
              'sfnumber: 4321, '
              'svnumber: 5678, '
              'fnumber: 8765, '
              'object: OtherClass(other: other_value), '
              'vnumber: 7890, '
              'string: some_string, '
              '_private: some_private_var, '
              'closure: Closure: (String) => Null)');
    });
  });
}
