import 'dart:convert';
import 'package:flutter/services.dart';

typedef JsonMap = Map<String, dynamic>;

PlatformException androidPlatformException({
  String? topFrameMethod,
  bool includeLineNumber = true,
  bool createChain = false,
}) {
  final JsonMap topTrace = {
    'exception': <String, dynamic>{
      'description': 'Invalid counter state: 1',
      'message': 'Invalid counter state: 1',
      'class': 'java.lang.IllegalStateException'
    },
    'frames': [
      <String, dynamic>{
        'filename': 'MainActivity.java',
        'method': topFrameMethod ?? 'getBatteryLevel',
        'class_name': 'com.rollbar.flutter.example.MainActivity',
        if (includeLineNumber) 'lineno': 47,
      },
      <String, dynamic>{
        'filename': 'MainActivity.java',
        'method': 'onMethodCall',
        'class_name': 'com.rollbar.flutter.example.MainActivity',
        if (includeLineNumber) 'lineno': 37,
      }
    ]
  };

  final JsonMap body = () {
    if (createChain) {
      const JsonMap secondTrace = {
        'exception': {
          'message': 'Rethrown Error',
          'class': 'java.lang.RethrownStuff'
        },
        'frames': [
          {'filename': 'MainActivity.java', 'method': 'processError'},
          {'filename': 'MainActivity.java', 'method': 'catchAndThrow'}
        ]
      };

      return {
        'trace_chain': [topTrace, secondTrace]
      };
    } else {
      return {'trace': topTrace};
    }
  }();

  final JsonMap platformTrace = {
    'data': {
      'body': body,
      'notifier': {
        'name': 'rollbar-java',
        'version': '0.0.1',
      }
    }
  };

  final message =
      'com.rollbar.flutter.RollbarTracePayload: ${jsonEncode(platformTrace)}';

  return PlatformException(code: 'error', message: message);
}
