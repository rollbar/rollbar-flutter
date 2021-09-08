class Client {
  String locale;

  String hostname;

  String os;

  String osVersion;

  String rootPackage;

  Map<String, String> dart;

  /// Converts the object into a Json encodable map.
  ///
  /// The `root` field is not supported by the backend as part of the `client` element,
  /// and it's being sent under the `server` element, though this might change in the future.
  /// See the file `core_notifier.dart` for details.
  Map<String, dynamic> toJson() {
    var result = <String, dynamic>{
      'locale': locale,
      'hostname': hostname,
      'os': os,
      'os_version': osVersion,
      'dart': dart
    };

    return result;
  }
}
