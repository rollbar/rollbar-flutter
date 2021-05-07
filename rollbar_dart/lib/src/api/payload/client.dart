class Client {
  String locale;

  String hostname;

  String os;

  String osVersion;

  Map<String, String> dart;

  Map<String, dynamic> toJson() {
    return {
      'locale': locale,
      'hostname': hostname,
      'os': os,
      'os_version': osVersion,
      'dart': dart
    };
  }
}
