import '_internal/module.dart';

/// [ServiceLocatorByType]
///
/// Helps in locating shared application wide services by their service types.
abstract class ServiceLocatorByType {
  void register<TService extends Object, T extends TService>(T service);

  bool registerIfNone<TService extends Object, T extends TService>(T service);

  TService? tryResolve<TService>();
  TService resolve<TService>();
}

/// [Service]
///
/// Models a service identifiable by its ID (as any Enum).
abstract class Service {
  Enum get id;
}

/// [ServiceBase]
///
/// The base class for defining a [Service].
abstract class ServiceBase extends Service {
  late final Enum _id;

  ServiceBase(Enum serviceID) {
    _id = serviceID;
  }

  @override
  Enum get id => _id;
}

/// [ServiceLocatorByID]
///
/// Helps in locating shared application wide services by their service IDs.
abstract class ServiceLocatorByID {
  void registerService(Service service);

  Service? tryResolveService(Enum serviceID);

  Service resolveService(Enum serviceID);
}

enum ServiceLocatorState {
  neverUsed,
  registrationPhase,
  queryPhase,
}

/// [ServiceLocator]
///
/// A generic reusable [ServiceLocator] that provides access to the shared
/// services by the service type and by the service ID.
class ServiceLocator implements ServiceLocatorByType, ServiceLocatorByID {
  ServiceLocatorState _state = ServiceLocatorState.neverUsed;
  final Map<Type, Object> _servicesByType = {};
  final Map<Enum, Service> _servicesByID = {};

  ServiceLocator._() {
    ModuleLogger.moduleLogger.finer('Created $ServiceLocator instance.');
  }
  bool _assertSafeTransitionTo(ServiceLocatorState state) {
    switch (state.index - _state.index) {
      case 1:
        _state = state;
        _validateCurrentState();
        return true;
      case 0:
        return true;
      default:
        throw AssertionError('''
          $runtimeType can not transition from $_state to $state.
          Make sure you register all expected singleton type objects
          before attempting to query for them.
          Once you start querying for the pre-registered types,
          you can not add any new registration!
          ''');
    }
  }

  void _validateCurrentState() {
    switch (_state) {
      case ServiceLocatorState.neverUsed:
        assert(_servicesByType.isEmpty && _servicesByID.isEmpty,
            '$_servicesByType and $_servicesByID must be empty while in the $_state state!');
        break;
      case ServiceLocatorState.registrationPhase:
      case ServiceLocatorState.queryPhase:
        assert(_servicesByType.isNotEmpty || _servicesByID.isNotEmpty,
            '$_servicesByType and $_servicesByID can not be empty while in the $_state state!');
        break;
      default:
        assert(false, 'Unexpected $_state state!');
        break;
    }
  }

  static final ServiceLocator instance = ServiceLocator._();

  @override
  TService? tryResolve<TService>() {
    _assertSafeTransitionTo(ServiceLocatorState.queryPhase);

    Object? result = _servicesByType[TService];
    if (result == null) {
      return null;
    }
    return result as TService;
  }

  @override
  TService resolve<TService>() {
    _assertSafeTransitionTo(ServiceLocatorState.queryPhase);
    TService? typeImplementation = tryResolve<TService>();

    if (typeImplementation != null) {
      return typeImplementation;
    } else {
      throw Exception(
          'Register implementation type for ${TService.runtimeType}');
    }
  }

  @override
  bool registerIfNone<TService extends Object, T extends TService>(
      T singleton) {
    if (!_servicesByType.containsKey(TService)) {
      _servicesByType[TService] = singleton;
      _assertSafeTransitionTo(ServiceLocatorState.registrationPhase);
      return true;
    } else {
      return false;
    }
  }

  @override
  void register<TService extends Object, T extends TService>(T singleton) {
    if (_servicesByType.containsKey(TService)) {
      throw Exception('Implementation type for $T is already registered');
    } else {
      _servicesByType[TService] = singleton;
      _assertSafeTransitionTo(ServiceLocatorState.registrationPhase);
    }
  }

  @override
  Service? tryResolveService(Enum serviceID) {
    return _servicesByID[serviceID];
  }

  @override
  Service resolveService(Enum serviceID) {
    _assertSafeTransitionTo(ServiceLocatorState.queryPhase);
    Service? serviceImplementation = tryResolveService(serviceID);

    if (serviceImplementation != null) {
      return serviceImplementation;
    } else {
      throw Exception(
          'Register service for the following service ID: $serviceID');
    }
  }

  @override
  void registerService(Service service) {
    _servicesByID[service.id] = service;
  }

  int get registrationsCount => _servicesByType.length + _servicesByID.length;
}
