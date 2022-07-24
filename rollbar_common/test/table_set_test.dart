import 'package:rollbar_common/src/persistable.dart';
import 'package:rollbar_common/src/table_set.dart';
import 'package:test/test.dart';

void main() {
  group('Datatype tests', () {
    test('Datatype sql type declaration is well formed', () {
      for (final datatype in Datatype.values) {
        switch (datatype) {
          case Datatype.uuid:
            expect(datatype.sqlTypeDeclaration,
                equals('BINARY(16) NOT NULL PRIMARY KEY'));
            break;
          case Datatype.integer:
            expect(datatype.sqlTypeDeclaration, equals('INTEGER NOT NULL'));
            break;
          case Datatype.real:
            expect(datatype.sqlTypeDeclaration, equals('REAL NOT NULL'));
            break;
          case Datatype.text:
            expect(datatype.sqlTypeDeclaration, equals('TEXT NOT NULL'));
            break;
          case Datatype.blob:
            expect(datatype.sqlTypeDeclaration, equals('BLOB NOT NULL'));
            break;
        }
      }
    });
  });
}
