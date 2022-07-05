import 'package:meta/meta.dart';
import '../../ext/collections.dart';

@immutable
class Client {
  final String locale;
  final String hostname;
  final String os;
  final String osVersion;
  final String rootPackage;
  final Map<String, String> dart;

  Client({
    required this.locale,
    required this.hostname,
    required this.os,
    required this.osVersion,
    required this.rootPackage,
    required this.dart,
  });

  /// Converts the object into a Json encodable map.
  ///
  /// The `root` field is not supported by the backend as part of the `client` element,
  /// and it's being sent under the `server` element, though this might change in the future.
  /// See the file `core_notifier.dart` for details.
  JsonMap toMap() => {
        'locale': locale,
        'hostname': hostname,
        'os': os,
        'os_version': osVersion,
        'dart': dart
      };
}
