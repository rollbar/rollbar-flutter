@Timeout(Duration(seconds: 145))

import 'dart:async';
//import 'dart:io';
//import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:rollbar_flutter/rollbar_flutter.dart';

const ConnectivityResult kCheckConnectivityResult = ConnectivityResult.wifi;

class MockConnectivityPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements ConnectivityPlatform {
  static const totalConnectivitySimulations = 20;
  final _interval = const Duration(seconds: 1);
  late final _timer;
  ConnectivityResult _currentConnectivity = ConnectivityResult.none;
  final _connectivityStreamController =
      StreamController<ConnectivityResult>.broadcast();

  MockConnectivityPlatform() {
    _timer = Timer.periodic(_interval, (timer) {
      // Stop the timer when it matches a condition
      if (timer.tick >= totalConnectivitySimulations) {
        timer.cancel();
      }
      int indx = ConnectivityResult.values.indexOf(_currentConnectivity);
      if (indx < ConnectivityResult.values.length - 1) {
        indx += 1;
      } else {
        indx = 0;
      }
      _currentConnectivity = ConnectivityResult.values[indx];
      print('Current connectivity: $_currentConnectivity');
      _connectivityStreamController.sink.add(_currentConnectivity);
    });
  }

  @override
  Future<ConnectivityResult> checkConnectivity() async {
    return kCheckConnectivityResult;
  }

  @override
  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivityStreamController.stream;
}

void main() {
  group('Connectivity monitor (Flutter):', () {
    MockConnectivityPlatform fakePlatform;
    setUp(() {
      fakePlatform = MockConnectivityPlatform();
      ConnectivityPlatform.instance = fakePlatform;
      // Additional setup goes here.
    });

    tearDown(() {});

    test('Basic operation test', () {});

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

    test('Test connectivity events stream via overrides', () async {
      int offCount = 0;
      int onCount = 0;

      var cm = ConnectivityMonitor();
      cm.onConnectivityChanged.listen(
          (state) => {state.connectivityOn ? onCount++ : offCount++},
          onDone: () => {expect(onCount + offCount, 3)});

      cm.overrideAsOn();
      cm.overrideAsOff();
      cm.overrideAsOn();

      cm.disposeOnConnectivityChanged();
    });

    test('Test connectivity events stream', () async {
      int count = 0;

      var cm = ConnectivityMonitor();
      cm.onConnectivityChanged.listen((state) {
        print(state);
        count += 1;
      }, onDone: () {
        expect(count > 0, true);
        print('Connectivity events count: $count.');
      });

      const simulationDuration = Duration(
          seconds: MockConnectivityPlatform.totalConnectivitySimulations + 1);
      //sleep(Duration(seconds: 100));
      await Future.delayed(simulationDuration);
      var expectedCount = 2 *
          (MockConnectivityPlatform.totalConnectivitySimulations /
              ConnectivityResult.values.length);
      expect(count, expectedCount);

      cm.disposeOnConnectivityChanged();
    });
  });
}
