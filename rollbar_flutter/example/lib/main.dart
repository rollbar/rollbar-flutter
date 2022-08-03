import 'dart:io' show Platform;
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rollbar_flutter/rollbar.dart';

/// Example Flutter application using rollbar-flutter.
Future<void> main() async {
  const config = Config(
      accessToken: '71ec6c76a22f46f0be567c633a3fb894',
      package: 'rollbar_flutter_example');

  await RollbarFlutter.run(config, () {
    Rollbar.log('Rollbar initialized');
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

  var _batteryLevel = 'Unknown battery level.';
  var _faultyMsg = 'No successful invocations yet.';
  var _counter = 0;

  MyHomePageState();

  void batteryLevel() async {
    String batteryLevel;
    try {
      final int level = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery at $level%.';
    } on PlatformException catch (e, stackTrace) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
      Rollbar.warn(e, stackTrace);
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  void faultyMethod() {
    platform
        .invokeMethod('faultyMethod')
        .then((message) => setState(() => _faultyMsg = message))
        .catchError((e) => log(e), test: (_) => false);
  }

  void incrementCounter() {
    setState(() {
      if (++_counter % 2 == 0) {
        throw ArgumentError('Unavoidable failure');
      } else {
        Rollbar.log('Counter incremented to $_counter');
      }
    });
  }

  void divideByZero() {
    1 ~/ 0;
  }

  void crash() {
    platform.invokeMethod('crash');
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
      ElevatedButton(
        onPressed: divideByZero,
        child: const Text('Divide by zero'),
      ),
      if (Platform.isIOS)
        ElevatedButton(
          onPressed: crash,
          child: const Text('Crash application'),
        ),
      const Divider(),
      const Text('Times you have pushed the plus button:'),
      Text(
        '$_counter',
        style: Theme.of(context).textTheme.headline4,
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
