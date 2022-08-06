import 'dart:core';

import 'package:uuid/uuid.dart';

/// This is our global UUID generator.
const uuidGen = Uuid();

typedef UUID = UuidValue;

abstract class Identifiable<T extends Object> {
  T get id;
}
