import 'package:flutter/foundation.dart';
import 'package:rollbar_common/rollbar_common.dart';

extension FlutterErrorDiagnostics on FlutterErrorDetails {
  List<String>? get information =>
      informationCollector?.call().map((e) => e.toStringDeep()).toList();
  List<Map<String, dynamic>>? get diagnostics =>
      informationCollector?.call().serialized();
}

extension _Serialize on Iterable<DiagnosticsNode> {
  // List<Map<String, Either<String, List<Map<String, Either...
  List<Map<String, dynamic>> serialized() => map((node) => {
        'name': node.name,
        'description': node.toDescription(),
        'value': node.value?.toString(),
        'properties': node.getProperties().serialized(),
        'children': node.getChildren().serialized(),
      }.compact()).toList();
}
