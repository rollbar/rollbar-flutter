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

/// Declaration of the [ConnectivityMonitor] interface.
abstract class ConnectivityMonitor {
  /// Current connectivity state.
  ConnectivityState get connectivityState;

  /// Stream of the [connectivityState] change events.
  Stream<ConnectivityState> get onConnectivityChanged;

  /// Manual connectivity state override as On.
  ///
  /// Any subsequent internally implemented connectivity Off-detection
  /// will override it.
  void overrideAsOn();

  /// Manual connectivity state override as Off.
  ///
  /// Any subsequent internally implemented connectivity On-detection
  /// will override it.
  void overrideAsOff();

  /// Manual connectivity state override as Off for a given duration of time.
  ///
  /// No subsequent internally implemented connectivity On-detection
  /// will override it during the specified duration.
  /// However, any subsequent internally implemented connectivity On-detection
  /// passed the duration perion will override it.
  ///
  /// This method is primerily used for unit testing purposes.
  void overrideAsOffFor({required Duration duration});

  /// Disables current manual connectivity state override (if any).
  void disableOverride();

  /// Initializesthis instance of the [ConnectivityMonitor].
  void initialize();

  /// Disposes of (closes) the [onConnectivityChanged] event stream forever.
  void disposeOnConnectivityChanged();
}

abstract class ConnectivityMonitorBase implements ConnectivityMonitor {
  static const bool defaultConnectivity = false;

  /// Connectivity status based on the detection method(s)
  /// implemented by this [ConnectivityMonitor].
  bool _connectivityOn = defaultConnectivity;

  /// Connectivity eoverride's exparation timestamp (if any).
  DateTime? _overrideExparationTimestamp;

  /// Signifies active connectivity status override for the [_connectivityOn].
  bool _activeOverride = false;

  /// Connectivity value to override [_connectivityOn] with.
  bool _connectivityOverride = defaultConnectivity;

  /// This is essentially a timestamped connectivity status derived based on
  /// the current values of
  /// [_connectivityOn], [_activeOverride], and [_connectivityOverride].
  ConnectivityState _connectivityState = ConnectivityState(defaultConnectivity);

  late final StreamController<ConnectivityState>
      _connectivityStateStreamController;

  @protected
  bool get connectivityOn => _connectivityOn;

  @protected
  set connectivityOn(bool value) {
    _connectivityOn = value;

    _recalculateConnectivity();
  }

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
    _overrideExparationTimestamp = null;
    _overrideState(true);
  }

  @override
  void overrideAsOff() {
    _overrideState(false);
  }

  @override
  void overrideAsOffFor({required Duration duration}) {
    _overrideExparationTimestamp = DateTime.now().add(duration);
    _overrideState(false);
  }

  void _overrideState(bool isConnected) {
    _connectivityOverride = isConnected;
    _activeOverride = true;

    _recalculateConnectivity();
  }

  @override
  void disableOverride() {
    _overrideExparationTimestamp = null;
    _activeOverride = false;

    _recalculateConnectivity();
  }

  @override
  ConnectivityState get connectivityState {
    _recalculateConnectivity();
    return _connectivityState;
  }

  bool _recalculateConnectivity() {
    if (_activeOverride &&
        (_overrideExparationTimestamp != null) &&
        (DateTime.now().millisecondsSinceEpoch >
            _overrideExparationTimestamp!.millisecondsSinceEpoch)) {
      _activeOverride = false;
      _overrideExparationTimestamp = null;
    }

    bool calculatedConnectivity =
        _activeOverride ? _connectivityOverride : _connectivityOn;

    if (calculatedConnectivity != _connectivityState.connectivityOn) {
      _connectivityState = ConnectivityState(calculatedConnectivity);
      if (_connectivityStateStreamController.hasListener) {
        _connectivityStateStreamController.sink.add(_connectivityState);
      }
    }

    return calculatedConnectivity;
  }
}
