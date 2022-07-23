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
    // we cannot judge the connectivity status based on unknown
    // active interfaces status, hence, let's consider it as connected:
    connectivityOn = await hasActiveNetworkInterface() ?? true;
  }

  /// Tests on availability of an active network interface.
  Future<bool?> hasActiveNetworkInterface() async {
    if (NetworkInterface.listSupported) {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        includeLinkLocal: false,
      );
      return interfaces.any((interface) => interface.addresses.isNotEmpty);
    } else {
      return null;
    }
  }

  /// Tests Internet connectivity to Rollbar.com.
  Future<bool> hasInternetConnectionToRollbar() async {
    try {
      final addresses = await InternetAddress.lookup('rollbar.com');
      return addresses.tryFirst?.rawAddress.isNotEmpty == true;
    } on SocketException catch (_) {
      return false;
    }
  }
}
