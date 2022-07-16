import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:rollbar_dart/rollbar_dart.dart' as rdart;
import 'package:rollbar_flutter/src/_internal/module.dart';

/// Service aiding in optimizing network operations.
/// [ConnectivityMonitor] is designed to work as a singleton.
///
/// Usage:
///
/// ```dart
/// void main() => runApp(MaterialApp(home: HomePage()));
///
/// class HomePage extends StatefulWidget {
///   @override
///   _HomePageState createState() => _HomePageState();
/// }
///
/// class _HomePageState extends State<HomePage> {
///   Map _source = {ConnectivityResult.none: false};
///   final MyConnectivity _connectivity = ConnectivityMonitor.instance;
///
///   @override
///   void initState() {
///     super.initState();
///     _connectivity.initialize();
///     _connectivity.myStream.listen((source) {
///       setState(() => _source = source);
///     });
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     String string;
///     switch (_source.keys.toList()[0]) {
///       case ConnectivityResult.mobile:
///         string = 'Mobile: Online';
///         break;
///       case ConnectivityResult.wifi:
///         string = 'WiFi: Online';
///         break;
///       case ConnectivityResult.none:
///       default:
///         string = 'Offline';
///     }
///
///     return Scaffold(
///       body: Center(child: Text(string)),
///     );
///   }
///
///   @override
///   void dispose() {
///     _connectivity.disposeStream();
///     super.dispose();
///   }
/// }
/// ```
///
////// Service aiding in optimizing network operations.
/// [ConnectivityMonitor] is designed to work as a singleton.
class ConnectivityMonitor extends rdart.ConnectivityMonitor {
  late final Connectivity _connectivity;
  late final StreamSubscription<ConnectivityResult> _connectivitySubscription;

  ConnectivityMonitor() {
    _connectivity = Connectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _processConnectivityEvent,
        onDone: _processConnectivityStreamCompletion,
        onError: _processConnectivityDetectionError);
  }

  void _processConnectivityEvent(ConnectivityResult connectivityResult) {
    switch (connectivityResult) {
      case ConnectivityResult.none:
        connectivityOn = false;
        break;
      case ConnectivityResult.ethernet:
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      default:
        connectivityOn = true;
        break;
    }
  }

  void _processConnectivityDetectionError(Object error, StackTrace stackTrace) {
    ModuleLogger.moduleLogger
        .warning('Connectivity Detection Error:', error, stackTrace);
  }

  void _processConnectivityStreamCompletion() {
    ModuleLogger.moduleLogger
        .info('Connectivity Detection Event Stream completed!');
  }

  @override
  void disposeOnConnectivityChanged() {
    _connectivitySubscription.cancel();
    super.disposeOnConnectivityChanged();
  }

  @override
  Future<void> checkConnectivity() async {
    switch (await _connectivity.checkConnectivity()) {
      case ConnectivityResult.none:
        connectivityOn = false;
        break;
      default:
        connectivityOn = await super.hasInternetConnectionToRollbar();
    }
  }
}
