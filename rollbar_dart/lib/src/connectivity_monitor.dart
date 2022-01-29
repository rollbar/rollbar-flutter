import 'dart:async';
import 'dart:io';

import 'package:rollbar_common/rollbar_common.dart';

/// Service aiding in optimizing network operations.
/// [ConnectivityMonitor] is designed to work as a singleton.
class ConnectivityMonitor extends ConnectivityMonitorBase {
  ConnectivityMonitor()
      : super(
            connectivityStateStreamController:
                StreamController<ConnectivityState>.broadcast());

  // Checks/updates connectivity status.
  Future<void> checkConnectivity() async {
    var hasActiveNetInterface = await hasActiveNetworkInterface();
    // we can not judje the connectivity status based on unknown
    // active interfaces status, hence, let's consider it as connected:
    connectivityOn = hasActiveNetInterface ?? true;
  }

  /// Tests on availability of an active network interface.
  Future<bool?> hasActiveNetworkInterface() async {
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
  Future<bool> hasInternetConnectionToRollbar() async {
    try {
      final result = await InternetAddress.lookup('rollbar.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  void overrideAsOffFor({required Duration duration}) {
    // TODO: implement overrideAsOffFor
  }
}
