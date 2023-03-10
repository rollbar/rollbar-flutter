import 'dart:mirrors';

import 'package:rollbar_common/rollbar_common.dart';

mixin DebugStringRepresentation {
  @override
  String toString() {
    final instanceMirror = reflect(this);

    final classMirror = instanceMirror.type;
    final className = MirrorSystem.getName(classMirror.simpleName);

    final variables = classMirror.declarations.whereValueType<VariableMirror>();
    final contents = variables.fold<List<String>>([], (acc, entry) {
      final symbol = entry.key, declaration = entry.value;
      final field = (declaration.isStatic ? classMirror : instanceMirror)
          .getField(symbol);

      final name = MirrorSystem.getName(declaration.simpleName);
      final value = field.hasReflectee ? '${field.reflectee}' : '?';

      return acc + ['$name: $value'];
    }).join(', ');

    return '$className($contents)';
  }
}
