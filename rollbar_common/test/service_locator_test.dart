import 'package:test/test.dart';

import 'package:rollbar_common/src/service_locator.dart';

enum ServiceSetA {
  a1,
  a2,
}

enum ServiceSetB {
  a1,
  a2,
}

class ServiceMock extends ServiceBase {
  ServiceMock(Enum serviceID) : super(serviceID);
}

abstract class Abstraction1 {}

class Concrete1 extends Abstraction1 {}

abstract class Abstraction2 {}

class Concrete2 implements Abstraction2 {}

void main() {
  group('Basic test sequence:', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Test initial state of the service locator', () {
      // ignore: invalid_use_of_protected_member
      expect(ServiceLocator.instance.registrationsCount, 0);
    });

    test('Test ID-based service registration', () {
      ServiceLocator.instance.registerService(ServiceMock(ServiceSetA.a1));
      ServiceLocator.instance.registerService(ServiceMock(ServiceSetA.a2));
      ServiceLocator.instance.registerService(ServiceMock(ServiceSetB.a1));
      ServiceLocator.instance.registerService(ServiceMock(ServiceSetB.a2));
      // ignore: invalid_use_of_protected_member
      expect(ServiceLocator.instance.registrationsCount, 4);
    });

    test('Test resolving service by ID', () {
      expect(ServiceLocator.instance.tryResolveService(ServiceSetA.a2) != null,
          true);
    });

    test('Test type-based service registration', () {
      ServiceLocator.instance.register<Abstraction1, Concrete1>(Concrete1());
      ServiceLocator.instance.register<Abstraction2, Concrete2>(Concrete2());
      // ignore: invalid_use_of_protected_member
      expect(ServiceLocator.instance.registrationsCount, 6);
    });

    test('Test resolving service by type', () {
      expect(ServiceLocator.instance.tryResolve<Abstraction2>() != null, true);
    });
  });
}
