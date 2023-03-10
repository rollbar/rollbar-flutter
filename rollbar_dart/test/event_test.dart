import 'dart:io';

import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:rollbar_common/rollbar_common.dart';
import 'package:rollbar_dart/rollbar_dart.dart';
import 'package:rollbar_dart/src/data/event.dart';
import 'package:test/test.dart';

void main() {
  group('Event tests', () {
    test('Events carry the correct data', () async {
      final telemetryEvent = TelemetryEvent(
        Breadcrumb.log('Some breadcrumb'),
      );
      final userEvent = UserEvent(User(
        id: '1234',
        username: 'someUser',
        email: 'some@email.com',
      ));
      final messageEvent = MessageEvent(
        'Some message',
        level: Level.debug,
      );
      final errorEvent = ErrorEvent(
        ArgumentError('Invalid argument'),
        StackTrace.empty,
        description: 'Some description',
        level: Level.critical,
      );

      final telemetryEventString = '$telemetryEvent';
      final userEventString = '$userEvent';
      final messageEventString = '$messageEvent';
      final errorEventString = '$errorEvent';

      expect(
          telemetryEventString,
          'TelemetryEvent(breadcrumb: Breadcrumb('
          'type: log, '
          'level: Level.info, '
          'source: Source.client, '
          'body: {message: Some breadcrumb}, '
          'timestamp: ${telemetryEvent.breadcrumb.timestamp}))');

      expect(
          userEventString,
          'UserEvent(user: User('
          'id: 1234, username: someUser, email: some@email.com))');

      expect(messageEventString,
          'MessageEvent(level: Level.debug, message: Some message)');

      expect(
          errorEventString,
          'ErrorEvent('
          'level: Level.critical, '
          'error: Invalid argument(s): Invalid argument, '
          'description: Some description, '
          'stackTrace: )');
    });
  });
}
