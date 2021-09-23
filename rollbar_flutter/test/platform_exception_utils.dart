import 'dart:convert';
import 'package:flutter/services.dart';

PlatformException createAndroidPlatformException(
    {String topFrameMethod,
    bool includeLineNumber = true,
    bool createChain = false}) {
  var topTrace = <String, dynamic>{
    'exception': {
      'description': 'Invalid counter state: 1',
      'message': 'Invalid counter state: 1',
      'class': 'java.lang.IllegalStateException'
    },
    'frames': [
      <String, dynamic>{
        'filename': 'MainActivity.java',
        'method': 'getBatteryLevel',
        'class_name': 'com.rollbar.flutter.example.MainActivity'
      },
      <String, dynamic>{
        'filename': 'MainActivity.java',
        'method': 'onMethodCall',
        'class_name': 'com.rollbar.flutter.example.MainActivity'
      }
    ]
  };

  // `jsonDecode` returns `dynamic` for everything, but it instatiates the most
  // applicable type in each case, which causes problems with dart's reified generics
  // when we need to get to the actual type. So it's best to test with and without
  // numbers in this case, which will produce either `Map<String, dynamic>` when numbers
  // are present, or `Map<String, String>` when they are not.
  if (includeLineNumber) {
    topTrace['frames'][0]['lineno'] = 47;
    topTrace['frames'][1]['lineno'] = 37;
  }

  var topFrame = topTrace['frames'][0];
  if (topFrameMethod != null) {
    topFrame['method'] = topFrameMethod;
  }

  Map<String, dynamic> body;

  if (createChain) {
    var secondTrace = {
      'exception': {
        'message': 'Rethrown Error',
        'class': 'java.lang.RethrownStuff'
      },
      'frames': [
        {'filename': 'MainActivity.java', 'method': 'processError'},
        {'filename': 'MainActivity.java', 'method': 'catchAndThrow'}
      ]
    };

    body = {
      'trace_chain': [topTrace, secondTrace]
    };
  } else {
    body = {'trace': topTrace};
  }

  var platformTrace = {
    'data': {
      'body': body,
      'notifier': {'name': 'rollbar-java', 'version': '0.0.1'}
    }
  };

  var message =
      'com.rollbar.flutter.RollbarTracePayload:' + json.encode(platformTrace);

  return PlatformException(code: 'error', message: message);
}
