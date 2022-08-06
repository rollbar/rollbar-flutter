import 'package:test/test.dart';
import 'package:rollbar_common/src/extension/mirror.dart';

void main() {
  group('Mirror Extensions', () {
    test('Symbol name is retrievable and correct.', () {
      expect((#String).name, equals('String'));
      expect((#Symbol).name, equals('Symbol'));
      expect((#String.substring).name, equals('String.substring'));
      expect((#[]=).name, equals('[]='));
      expect((#[]).name, equals('[]'));
      expect((#==).name, equals('=='));
      expect((#+).name, equals('+'));
      expect((#-).name, equals('-'));
      expect((#%).name, equals('%'));
      expect((#^).name, equals('^'));
      expect((#&).name, equals('&'));
      expect((#*).name, equals('*'));
      expect((#~).name, equals('~'));
      expect((#|).name, equals('|'));
      expect((#/).name, equals('/'));
      expect((#implements).name, equals('implements'));
      expect((#extension).name, equals('extension'));
      expect((#abstract).name, equals('abstract'));
      expect((#static).name, equals('static'));
      expect((#async).name, equals('async'));
      expect((#import).name, equals('import'));
      expect((#mixin).name, equals('mixin'));
      expect((#void).name, equals('void'));
      expect((#get).name, equals('get'));
      expect((#set).name, equals('set'));
      expect((#on).name, equals('on'));
    });
  });
}
