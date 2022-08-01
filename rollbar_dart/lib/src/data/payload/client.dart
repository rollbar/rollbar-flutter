import 'package:meta/meta.dart';
import 'package:rollbar_common/rollbar_common.dart';

@sealed
@immutable
class Client
    with EquatableSerializableMixin
    implements Equatable, Serializable {
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

  factory Client.fromMap(JsonMap map) => Client(
      locale: map['locale'],
      hostname: map['hostname'],
      os: map['os'],
      osVersion: map['os_version'],
      dartVersion: map['dart']['version'],

  /// Converts the object into a Json encodable map.
  @override
  JsonMap toMap() => {
        'locale': locale,
        'hostname': hostname,
        'os': os,
        'os_version': osVersion,
        'dart': {'version': dartVersion},
      };
}
