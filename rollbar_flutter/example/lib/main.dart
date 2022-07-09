import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rollbar_dart/rollbar.dart';
import 'package:rollbar_flutter/rollbar.dart';

late final Rollbar rollbar;

/// Example Flutter application using rollbar-flutter.
Future<void> main() async {
  final config = Config(
    accessToken: '71ec6c76a22f46f0be567c633a3fb894',
    environment: 'development',
    codeVersion: '0.3.0',
    package: 'rollbar_flutter_example',
    handleUncaughtErrors: true,
    includePlatformLogs: false,
  );

  rollbar = await RollbarFlutter.start(config: config);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rollbar Flutter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Rollbar Flutter Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('com.rollbar.flutter.example/activity');

  var _lastError = 'No errors yet';
  var _batteryLevel = 'Unknown battery level.';
  var _faultyMsg = 'No successful invocations yet.';
  var _counter = 0;

  _MyHomePageState();

  Future<void> batteryLevel() async {
    await platform
        .invokeMethod('getBatteryLevel')
        .then((level) => setState(() => _batteryLevel = 'Battery at $level%.'))
        .catchError(
          (_) => setState(() => _lastError = 'No battery data.'),
          test: (error) => error is PlatformException,
        );
  }

  Future<void> faultyMethod() async {
    await platform
        .invokeMethod('faultyMethod')
        .then((message) => setState(() => _faultyMsg = message))
        .catchError(
          (error) => setState(() => _lastError = error.toString()),
          test: (_) => false,
        );
  }

  void incrementCounter() {
    setState(() {
      if (++_counter % 2 == 0) {
        throw ArgumentError('Unavoidable failure');
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
        child: Text('Get Battery Level'),
      ),
      Text(_batteryLevel),
      ElevatedButton(
        onPressed: faultyMethod,
        child: Text('Call Faulty Method'),
      ),
      Text(_faultyMsg),
      ElevatedButton(
        onPressed: divideByZero,
        child: Text('Divide by zero'),
      ),
    ];

    if (Platform.isIOS) {
      bodyChildren.add(
        ElevatedButton(
          onPressed: crash,
          child: Text('Crash application'),
        ),
      );
    }

    bodyChildren.addAll(<Widget>[
      Divider(),
      Text('Times you have pushed the plus button:'),
      Text(
        '$_counter',
        style: Theme.of(context).textTheme.headline4,
      ),
      Divider(height: 10),
      Text(
        'Most recent Flutter error:',
        style: Theme.of(context).textTheme.headline6,
      ),
      Padding(
        padding: EdgeInsets.only(top: 16),
        child: Text(
          _lastError,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      )
    ]);

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
        child: Icon(Icons.add),
      ),
    );
  }
}
