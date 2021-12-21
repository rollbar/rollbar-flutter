import 'dart:async';
import 'dart:io';

/// Service aiding in optimizing network operations.
/// [ConnectivityMonitor] is designed to work as a singleton.
class ConnectivityMonitor {
  static ConnectivityMonitor? _singleton;

  /// Hides default constructor.
  ConnectivityMonitor._();

  /// Constructs/returns a singleton instance of [ConnectivityMonitor].
  ///
  /// [ConnectivityMonitor] is designed to work as a singleton.
  factory ConnectivityMonitor.singleton() {
    _singleton ??= ConnectivityMonitor._();
    return _singleton!;
  }

  /// Connectivity status.
  bool get connected => _connected;
  bool _connected = false;

  // Checks/updates connectivity status.
  Future<void> checkConnectivity() async {
    var hasActiveNetInterface = await hasActiveNetworkInterface();
    if (hasActiveNetInterface == null) {
      // we can not judje the connectivity statis based on unknown
      // active interfaces status, hence, let's consider it as connected:
      _connected = true;
    } else {
      _connected = hasActiveNetInterface;
    }
  }

  /// Tests on availability of an active network interface.
  FutureOr<bool?> hasActiveNetworkInterface() async {
    if (!NetworkInterface.listSupported) {
      return null; // we don't really know one way or another...
    }

    var netInterfaces = await NetworkInterface.list(
        includeLoopback: false, includeLinkLocal: false);
    for (var ni in netInterfaces) {
      if (ni.addresses.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// Tests Internet connectivity to Rollbar.com.
  FutureOr<bool> hasInternetConnectionToRollbar() async {
    try {
      final result = await InternetAddress.lookup('rollbar.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
