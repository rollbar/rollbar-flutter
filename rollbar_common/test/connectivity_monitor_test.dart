import 'package:test/test.dart';

import 'package:rollbar_common/src/connectivity_monitor.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Check Connectivity', () async {
      // here we assume that the tests are always ran on a dev machine or
      // a CI server that have an active network interface:
      expect(
          await ConnectivityMonitor.singleton().hasActiveNetworkInterface(), true);
    });
  });
}
