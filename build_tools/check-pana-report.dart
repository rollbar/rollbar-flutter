import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> arguments) async {
  final reportPath = arguments[0];
  final targetsPath = arguments[1];

  var panaResult = await getJsonDict(reportPath);
  var targets = await getJsonDict(targetsPath);

  var failed = false;

  for (var section in panaResult['report']['sections']) {
    var sectionId = section['id'];

    if (targets.containsKey(sectionId)) {
      double target = targets[sectionId].toDouble();
      num maxPoints = section['maxPoints'];
      num grantedPoints = section['grantedPoints'];
      double ratio = grantedPoints.toDouble() / maxPoints.toDouble();

      if (ratio < target) {
        failed = true;
        stderr.writeln(
            'BAD: section ${sectionId}, target: ${target}, actual: ${ratio}');
        stderr.writeln(section['summary']);
      } else {
        stderr.writeln(
            'OK: section ${sectionId}, target: ${target}, actual: ${ratio}');
      }
    } else {
      failed = true;
      stderr.writeln('No target for section ${sectionId}');
    }
  }

  if (failed) {
    exit(1);
  }
}

Future<Map<String, dynamic>> getJsonDict(String filename) async {
  File file = File.fromUri(Uri.file(filename));
  return jsonDecode(await file.readAsString());
}
