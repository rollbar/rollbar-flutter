import 'dart:io' show Platform;
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rollbar_flutter/rollbar.dart' show Rollbar, RollbarFlutter;
import 'package:rollbar_flutter/rollbar.dart' as rollbar;

/// Example Flutter application using rollbar-flutter.
Future<void> main() async {
  const config = rollbar.Config(
      accessToken: 'YOUR-ROLLBAR-ACCESSTOKEN',
      package: 'rollbar_flutter_example');

  await RollbarFlutter.run(config, () {
    Rollbar.drop(rollbar.Breadcrumb.navigation(
      from: 'initialize',
      to: 'runApp',
    ));
    Rollbar.info('Rollbar initialized');
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rollbar Flutter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Rollbar Flutter Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('com.rollbar.flutter.example/activity');

  var _userIsLoggedIn = false;
  var _setUserText = 'Set User';

  var _batteryLevel = 'Unknown battery level.';
  var _faultyMsg = 'No successful invocations yet.';
  var _counter = 0;

  MyHomePageState();

  void batteryLevel() async {
    Rollbar.drop(
      rollbar.Breadcrumb.widget(
        element: 'batteryLevel',
        extra: const {'action': 'tapped'},
      ),
    );

    String batteryLevel;
    try {
      final int level = await platform.batteryLevel;
      batteryLevel = 'Battery at $level%.';
    } on PlatformException catch (e, stackTrace) {
      batteryLevel = 'Failed to get battery level.';
      Rollbar.drop(
        rollbar.Breadcrumb.error(
            'Non-fatal PlatformException while getting battery level.'),
      );
      Rollbar.warn(e, stackTrace);
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  void faultyMethod() {
    Rollbar.drop(rollbar.Breadcrumb.log('Tapped faultyMethod button'));
    Rollbar.warn('This method is about to fail');
    platform
        .faultyMethod()
        .then((message) => setState(() => _faultyMsg = message))
        .catchError((e) => log(e), test: (_) => false);
  }

  void incrementCounter() {
    Rollbar.drop(rollbar.Breadcrumb.widget(
      element: 'incrementCounter',
      extra: const {'action': 'tapped'},
    ));

    setState(() {
      if (++_counter % 2 == 0) {
        throw ArgumentError('Failed to increment counter');
      } else {
        Rollbar.drop(
          rollbar.Breadcrumb.log('Counter incremented to $_counter'),
        );
      }
    });
  }

  void asyncFailure() {
    _asyncFailure(1).then((n) => log('$n ~/ 0 = ???'));
  }

  Future<int> _asyncFailure(int num) async {
    return Future<int>.delayed(Duration(seconds: num), () => num ~/ 0);
  }

  void setUser() {
    if (_userIsLoggedIn) {
      Rollbar.setUser(null);
      _userIsLoggedIn = false;
      Rollbar.debug('User logged out');
    } else {
      Rollbar.setUser(const rollbar.User(
        id: '123456',
        username: 'TheUser',
        email: 'user@email.co',
      ));
      _userIsLoggedIn = true;
      Rollbar.debug('User logged in');
    }

    setState(() {
      _setUserText = _userIsLoggedIn ? 'Unset User' : 'Set User';
    });
  }

  void throwError() {
    Rollbar.drop(rollbar.Breadcrumb.log('Tapped throwError button'));
    Rollbar.critical('About to throw an error!');
    throw StateError('A state error occurred');
  }

  void crash() {
    Rollbar.drop(rollbar.Breadcrumb.navigation(from: 'app', to: 'crash'));
    platform.crash();
  }

  @override
  Widget build(BuildContext context) {
    final bodyChildren = <Widget>[
      ElevatedButton(
        onPressed: batteryLevel,
        child: const Text('Get Battery Level'),
      ),
      Text(_batteryLevel),
      ElevatedButton(
        onPressed: faultyMethod,
        child: const Text('Call Faulty Method'),
      ),
      Text(_faultyMsg),
      if (Platform.isIOS)
        ElevatedButton(
          onPressed: crash,
          child: const Text('Crash application'),
        ),
      const Divider(),
      ElevatedButton(
        onPressed: setUser,
        child: Text(_setUserText),
      ),
      const Divider(),
      ElevatedButton(
        onPressed: asyncFailure,
        child: const Text('Async failure'),
      ),
      ElevatedButton(
        onPressed: throwError,
        child: const Text('Throw error'),
      ),
      const Divider(),
      const Text('Times you have pushed the plus button:'),
      Text(
        '$_counter',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const Divider(height: 10),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: bodyChildren,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

extension _Methods on MethodChannel {
  Future<int> get batteryLevel async => await invokeMethod('getBatteryLevel');
  Future<String> faultyMethod() async => await invokeMethod('faultyMethod');
  Future<Never> crash() async => await invokeMethod('crash');
}
