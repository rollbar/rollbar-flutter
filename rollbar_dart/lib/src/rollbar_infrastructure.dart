import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:async/async.dart';
import 'package:rollbar_common/rollbar_common.dart';
import 'package:rollbar_dart/rollbar_dart.dart';

import '_internal/module.dart';
import 'payload_repository/payload_repository.dart';

class RollbarInfrastructure {
  late final SendPort _sendPort;
  late final ReceivePort _receivePort;

  RollbarInfrastructure._() {
    _receivePort = ReceivePort();
    Isolate.spawn(_processWorkItemsInBackground, _receivePort.sendPort,
        debugName: 'RollbarInfrastructureIsolate');
  }

  Future<SendPort> initialize({required Config rollbarConfig}) async {
    _sendPort = await _receivePort.first;
    ModuleLogger.moduleLogger.info('Send port: $_sendPort');
    _sendPort.send(rollbarConfig);
    return _sendPort;
  }

  Future<void> dispose() async {
    // Send a signal to the spawned isolate indicating that it should exit:
    _sendPort.send(null);
  }

  static final RollbarInfrastructure instance = RollbarInfrastructure._();

  void process({required PayloadRecord record}) {
    _sendPort.send(record);
  }

  static Future<void> _processWorkItemsInBackground(SendPort sendPort) async {
    ModuleLogger.moduleLogger.info('Infrastructure isolate started.');

    // Send a SendPort to the main isolate (RollbarInfrastructure)
    // so that it can send JSON strings to this isolate:
    final commandPort = ReceivePort();
    sendPort.send(commandPort.sendPort);

    // Wait for messages from the main isolate.
    await for (final message in commandPort) {
      // cast the message to one of the expected message types,
      // handle it properly, compile a response and send it back via
      // the SendPort p if needed:
      // For example,
      if (message is Config) {
        if (ServiceLocator.instance.registrationsCount == 0) {
          ServiceLocator.instance
              .register<PayloadRepository, PayloadRepository>(
                  PayloadRepository.create(message.persistPayloads ?? false));
        }
      } else if (message is PayloadRecord) {
        //_payloadRepository.addPayloadRecord(message);
        ServiceLocator.instance
            .tryResolve<PayloadRepository>()
            ?.addPayloadRecord(message);
      } else if (message is String) {
        // Read and decode the file.
        //final contents = await File(message).readAsString();

        // Send the result to the main isolate.
        //p.send(jsonDecode(contents));
      } else if (message == null) {
        // Exit if the main isolate sends a null message, indicating there are no
        // more files to read and parse.
        break;
      }
    }

    ModuleLogger.moduleLogger.info('Infrastructure isolate finished.');
    Isolate.exit();
  }
}
