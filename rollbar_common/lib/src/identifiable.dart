import 'dart:core';

import 'package:uuid/uuid.dart';

/// This is our global UUID generator.
const uuidGen = Uuid();

typedef UUID = UuidValue;

final nilUUID = UUID("00000000-0000-0000-0000-000000000000");

abstract class Identifiable<T extends Object> {
  T get id;
}

extension IterableIntoUUID on Iterable<int> {
  UUID toUUID() => UUID.fromList(toList());
}

extension StringIntoUUID on String {
  UUID toUUID() => RegExp(r'\w\w')
      .allMatches(this)
      .map((match) => int.parse(match[0]!, radix: 16))
      .toUUID();
}
