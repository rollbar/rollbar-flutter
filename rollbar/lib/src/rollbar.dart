import 'dart:convert';
import 'dart:io' show Platform;

import 'package:http/http.dart' as http;
import 'package:stack_trace/stack_trace.dart';

import 'config.dart';

class Rollbar {
  final Config _config;

  Rollbar(this._config);

  Future<dynamic> error(dynamic error, dynamic stackTrace) async {
    final headers = <String, String>{
      'User-Agent': 'rollbar-dart',
      'Content-Type': 'application/json',
      'X-Rollbar-Access-Token': _config.accessToken,
    };

    var body = {
      'trace': {
        'frames': Trace.from(stackTrace).frames.map((frame) {
          return {
            'colno': frame.column,
            'lineno': frame.line,
            'method': frame.member,
            'filename': Uri.parse(frame.uri.toString()).path,
          };
        }).toList(),
        'exception': {
          'class': error.runtimeType.toString(),
          'message': error.toString()
        }
      }
    };
    final data = <String, dynamic>{
      'body': body,
      'timestamp': DateTime.now().microsecondsSinceEpoch,
      'language': 'dart',
      'platform': Platform.operatingSystem,
      'client': {
        'locale': Platform.localeName,
        'hostname': Platform.localHostname,
        'os': Platform.operatingSystem,
        'os_version': Platform.operatingSystemVersion,
        'dart': {
          'version': Platform.version,
        }
      },
      'environment': _config.environment,
      'notifier': {'version': '0.0.1', 'name': 'rollbar-dart'},
    };

    final response = await http.post(_config.endpoint,
        headers: headers, body: json.encode({'data': data}));
    return response;
  }
}
