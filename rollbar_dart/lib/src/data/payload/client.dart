import 'dart:io';
import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

@sealed
@immutable
class Client {
  final String locale;
  final String hostname;
  final String os;
  final String osVersion;
  final String dartVersion;

  const Client({
    required this.locale,
    required this.hostname,
    required this.os,
    required this.osVersion,
    required this.dartVersion,
  });

  factory Client.fromPlatform() => Client(
        locale: Platform.localeName,
        hostname: Platform.localHostname,
        os: Platform.operatingSystem,
        osVersion: Platform.operatingSystemVersion,
        dartVersion: Platform.version,
      );

  /// Converts the object into a Json encodable map.
  JsonMap toMap() => {
        'locale': locale,
        'hostname': hostname,
        'os': os,
        'os_version': osVersion,
        'dart': {'version': dartVersion}
      };
}
