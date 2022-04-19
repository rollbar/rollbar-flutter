//import 'dart:ffi';
//import 'dart:io';

import 'package:test/test.dart';

import 'package:rollbar_dart/src/connectivity_monitor.dart';

void main() {
  group('Connectivity monitor (Dart):', () {
    tearDown(() {});

    test('Test active network interface', () async {
      var cm = ConnectivityMonitor();
      // here we assume that the tests are always ran on a dev machine or
      // a CI server that have an active network interface:
      expect(await cm.hasActiveNetworkInterface(), true);
    });

    test('Test connectivity to Rollbar.com', () async {
      var cm = ConnectivityMonitor();
      // here we assume that the tests are always ran on a dev machine or
      // a CI server that have an active network interface:
      expect(await cm.hasInternetConnectionToRollbar(), true);
    });

    test('Test connectivity events stream', () async {
      int offCount = 0;
      int onCount = 0;

      var cm = ConnectivityMonitor();
      cm.onConnectivityChanged.listen(
          (state) => {state.connectivityOn ? onCount++ : offCount++},
          onDone: () => {expect(onCount + offCount, 2)});

      cm.overrideAsOn();
      cm.overrideAsOff();
      cm.overrideAsOn();

      cm.disposeOnConnectivityChanged();
    });

    test('Test connectivity OFF override times out', () async {
      int offCount = 0;
      int onCount = 0;

      var cm = ConnectivityMonitor();
      expect(cm.connectivityState.connectivityOn, true);
      cm.onConnectivityChanged.listen(
          (state) => {state.connectivityOn ? onCount++ : offCount++},
          onDone: () => {expect(onCount + offCount, 2)});

      cm.overrideAsOn();
      expect(cm.connectivityState.connectivityOn, true);
      cm.overrideAsOffFor(duration: Duration(seconds: 2));
      expect(cm.connectivityState.connectivityOn, false);
      final stateOff = cm.connectivityState;
      print('stateOff: $stateOff');
      await Future.delayed(Duration(seconds: 3));
      final state = cm.connectivityState;
      print('stateOn: $state');
      expect(cm.connectivityState.connectivityOn, true);

      cm.disposeOnConnectivityChanged();
    });
  });
}
