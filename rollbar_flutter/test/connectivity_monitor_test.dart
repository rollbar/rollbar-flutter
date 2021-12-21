import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'dart:async';

import 'package:rollbar_flutter/rollbar_flutter.dart';

void main() {
  setUp(() {
    ConnectivityMonitor.instance.initialize();
    ConnectivityMonitor.instance.eventStream.listen((event) {
      var e = event;
    });
  });

  tearDown(() {});

  test('Basic operation test', () {
    expect(ConnectivityMonitor.instance.connectivityOn, equals(true));
  });
}
