import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:rollbar_common/rollbar_common.dart';
import 'package:rollbar_dart/rollbar.dart';

Data dataFrom({required Body body}) => Data(
      body: body,
      timestamp: DateTime.now().microsecondsSinceEpoch,
      language: 'dart',
      level: Level.error,
      platform: Platform.operatingSystem,
      framework: 'flutter',
      codeVersion: 'someCodeVersion',
      client: Client.fromPlatform(),
      environment: 'unitTesting',
      notifier: const {'version': 'someVersion', 'name': 'someName'},
      server: const {'root': 'com.some.package'},
    );

Trace platformTraceInfo(PlatformException exception, List<Frame> frames) =>
    Trace(
      exception: ExceptionInfo(
        type: exception.runtimeType.toString(),
        message: exception.toString(),
      ),
      frames: frames,
    );
