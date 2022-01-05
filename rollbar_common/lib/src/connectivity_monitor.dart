import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';

class ConnectivityState {
  final bool connectivityOn;

  const ConnectivityState({
    required this.connectivityOn,
  });

  ConnectivityState copyWith({
    bool? connectivityOn,
  }) {
    return ConnectivityState(
      connectivityOn: connectivityOn ?? this.connectivityOn,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'connectivityOn': connectivityOn,
    };
  }

  factory ConnectivityState.fromMap(Map<String, dynamic> map) {
    return ConnectivityState(
      connectivityOn: map['connectivityOn'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ConnectivityState.fromJson(String source) =>
      ConnectivityState.fromMap(json.decode(source));

  @override
  String toString() => 'ConnectivityState(connectivityOn: $connectivityOn)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConnectivityState && other.connectivityOn == connectivityOn;
  }

  @override
  int get hashCode => connectivityOn.hashCode;
}

abstract class ConnectivityMonitor {
  ConnectivityState get connectivityState;

  Stream<ConnectivityState> get onConnectivityChanged;

  void overrideAsOn();

  void overrideAsOff();

  void disableOverride();

  void initialize();

  void disposeOnConnectivityChanged();
}

abstract class ConnectivityMonitorBase implements ConnectivityMonitor {
  bool _connectivityOn = false;

  @protected
  bool get connectivityOn => _connectivityOn;

  @protected
  set connectivityOn(bool value) {
    if (value == _connectivityOn) {
      return; // not a change really...
    }

    _connectivityOn = value;
    if (!_activeOverride && _connectivityStateStreamController.hasListener) {
      _connectivityStateStreamController.sink
          .add(ConnectivityState(connectivityOn: value));
    }
  }

  bool _activeOverride = false;

  bool _connectivityOverride = false;

  late final StreamController<ConnectivityState>
      _connectivityStateStreamController;

  ConnectivityMonitorBase(
      {required StreamController<ConnectivityState>
          connectivityStateStreamController}) {
    _connectivityStateStreamController = connectivityStateStreamController;
  }

  @override
  Stream<ConnectivityState> get onConnectivityChanged =>
      _connectivityStateStreamController.stream;

  @override
  void initialize() {}

  @override
  void disposeOnConnectivityChanged() {
    _connectivityStateStreamController.close();
  }

  @override
  void overrideAsOn() {
    _overrideState(true);
  }

  @override
  void overrideAsOff() {
    _overrideState(false);
  }

  void _overrideState(bool isConnected) {
    _connectivityOverride = isConnected;
    _activeOverride = true;
    if (_connectivityStateStreamController.hasListener) {
      _connectivityStateStreamController.sink
          .add(ConnectivityState(connectivityOn: isConnected));
    }
  }

  @override
  void disableOverride() {
    _activeOverride = false;
    if (_connectivityStateStreamController.hasListener) {
      _connectivityStateStreamController.sink
          .add(ConnectivityState(connectivityOn: _connectivityOn));
    }
  }

  @override
  ConnectivityState get connectivityState {
    return ConnectivityState(
        connectivityOn:
            _activeOverride ? _connectivityOverride : connectivityOn);
  }
}
