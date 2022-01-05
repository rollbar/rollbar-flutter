import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';

class ConnectivityState {
  late final DateTime timestamp;
  final bool connectivityOn;

  ConnectivityState(this.connectivityOn, [DateTime? timestamp]) {
    this.timestamp = timestamp ?? DateTime.now();
  }

  ConnectivityState copyWith({
    DateTime? timestamp,
    bool? connectivityOn,
  }) {
    return ConnectivityState(
        connectivityOn ?? this.connectivityOn, timestamp ?? DateTime.now());
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'connectivityOn': connectivityOn,
    };
  }

  factory ConnectivityState.fromMap(Map<String, dynamic> map) {
    return ConnectivityState(
      map['connectivityOn'] ?? false,
      DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ConnectivityState.fromJson(String source) =>
      ConnectivityState.fromMap(json.decode(source));

  @override
  String toString() =>
      'ConnectivityState(connectivityOn: $connectivityOn, timestamp: $timestamp)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConnectivityState &&
        other.timestamp == timestamp &&
        other.connectivityOn == connectivityOn;
  }

  @override
  int get hashCode => timestamp.hashCode ^ connectivityOn.hashCode;
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
      _connectivityStateStreamController.sink.add(ConnectivityState(value));
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
          .add(ConnectivityState(isConnected));
    }
  }

  @override
  void disableOverride() {
    _activeOverride = false;
    if (_connectivityStateStreamController.hasListener) {
      _connectivityStateStreamController.sink
          .add(ConnectivityState(_connectivityOn));
    }
  }

  @override
  ConnectivityState get connectivityState {
    return ConnectivityState(
        _activeOverride ? _connectivityOverride : connectivityOn);
  }
}
