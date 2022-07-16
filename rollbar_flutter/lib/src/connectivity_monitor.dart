import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:rollbar_dart/rollbar_dart.dart';

/// Service aiding in optimizing network operations.
/// [FlutterConnectivityMonitor] is designed to work as a singleton.
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
/// [FlutterConnectivityMonitor] is designed to work as a singleton.
class FlutterConnectivityMonitor extends ConnectivityMonitor {
  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<ConnectivityResult> _connectivitySubscription;

  FlutterConnectivityMonitor() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (status) {
        connectivityOn = status != ConnectivityResult.none;
      },
    );
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
