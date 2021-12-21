import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Service aiding in optimizing network operations.
/// [ConnectivityMonitor] is designed to work as a singleton.
///
/// Usage:
///
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
///
class ConnectivityMonitor {
  static final ConnectivityMonitor _singleton = ConnectivityMonitor._();

  /// Hides default constructor.
  ConnectivityMonitor._();

  /// Constructs/returns the service's singleton instance of [ConnectivityMonitor].
  ///
  /// [ConnectivityMonitor] is designed to work as a singleton.
  factory ConnectivityMonitor.singleton() {
    return _singleton;
  }

  // Accessor to the service instance of [ConnectivityMonitor].
  static ConnectivityMonitor get instance => _singleton;

  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();
  bool _connectivityOn = false;
  Stream<bool> get eventStream => _controller.stream;

  void initialize() {
    _connectivity
        .checkConnectivity()
        .then((value) => _checkStatus(value))
        .onError((error, stackTrace) => null);
    // try {
    //   ConnectivityResult result = await _connectivity.checkConnectivity();
    //   _checkStatus(result);
    //   _connectivity.onConnectivityChanged.listen((result) {
    //     _checkStatus(result);
    //   });
    // } catch (e) {
    //   _checkStatus(ConnectivityResult.none);
    // }
  }

  void _checkStatus(ConnectivityResult result) {
    bool isOnline = false;
    InternetAddress.lookup('example.com')
        .then((value) =>
            isOnline = value.isNotEmpty && value[0].rawAddress.isNotEmpty)
        .onError((error, stackTrace) => isOnline = false)
        .whenComplete(() => {});
    _connectivityOn = isOnline;
    if (_activeOverride != true) {
      _controller.sink.add(isOnline); //({result: isOnline});
    }

    // try {
    //   final result = await InternetAddress.lookup('example.com');
    //   isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    // } on SocketException catch (_) {
    //   isOnline = false;
    // }
    // _connectivityOn = isOnline;
    // if (_activeOverride != true) {
    //   _controller.sink.add(isOnline); //({result: isOnline});
    // }
  }

  void disposeStream() => _controller.close();

  bool _activeOverride = false;
  bool _connectivityOverride = false;

  void overrideAsOn() {
    _overrideState(true);
  }

  void overrideAsOff() {
    _overrideState(false);
  }

  void _overrideState(bool isConnected) {
    _connectivityOverride = isConnected;
    _activeOverride = true;
    _controller.sink.add(isConnected);
  }

  void disableOverride() {
    _activeOverride = false;
    _controller.sink.add(_connectivityOn);
  }

  bool get connectivityOn {
    return _activeOverride ? _connectivityOverride : _connectivityOn;
  }
}
