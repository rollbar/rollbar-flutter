import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rollbar_flutter/rollbar.dart';

/// Example Flutter application using rollbar-flutter.
Future<void> main() async {
  var config = (ConfigBuilder('<YOUR ROLLBAR TOKEN HERE>')
        ..environment = 'development'
        ..codeVersion = '0.1.0'
        ..package = 'rollbar_flutter_example'
        ..handleUncaughtErrors = true
        ..includePlatformLogs = false)
      .build();

  await RollbarFlutter.run(config, (_rollbar) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Rollbar Flutter example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('com.rollbar.flutter.example/activity');

  int _counter = 0;
  final _lastError = 'No errors yet';
  String _batteryLevel = 'Unknown battery level.';
  String _faultyMsg = 'No successful invocations yet.';

  _MyHomePageState();

  Future<void> _getBatteryLevel() async {
    var batteryLevelMsg = await _getBatteryLevelMsg();
    setState(() {
      _batteryLevel = batteryLevelMsg;
    });
  }

  Future<String> _getBatteryLevelMsg() async {
    String batteryLevel;
    final result = await platform.invokeMethod('getBatteryLevel');
    batteryLevel = 'Battery level at $result % .';
    return batteryLevel;
  }

  Future<void> _faultyMethod() async {
    var msg = await _getFaultyMethodMsg();
    setState(() {
      _faultyMsg = msg;
    });
  }

  Future<String> _getFaultyMethodMsg() async {
    try {
      return await platform.invokeMethod('faultyMethod');
    } catch (error, _) {
      rethrow;
    }
  }

  Future<void> _incrementCounter() async {
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      _counter++;
      if (_counter % 2 == 0) {
        throw ArgumentError('Unavoidable failure');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // If we ever remove Flutter 1 support, this should be updated to [ElevatedButton]
            // ignore: deprecated_member_use
            RaisedButton(
              onPressed: _getBatteryLevel,
              child: Text('Get Battery Level'),
            ),
            Text(_batteryLevel),
            // ignore: deprecated_member_use
            RaisedButton(
              onPressed: _faultyMethod,
              child: Text('Call Faulty Method'),
            ),
            Text(_faultyMsg),
            Divider(),
            Text(
              'Times you have pushed the plus button:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            Divider(),
            Text(
              'Most recent Flutter error:',
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
              _lastError,
              style: Theme.of(context).textTheme.caption,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
