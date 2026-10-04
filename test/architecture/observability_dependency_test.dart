import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OBS-ARCH-001 features only import the observability seam', () {
    final featureFiles = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    const observabilityPath = 'core/services/observability/';
    const allowedSeamFile = 'observability_provider.dart';

    for (final file in featureFiles) {
      for (final line in file.readAsLinesSync()) {
        if (!line.contains(observabilityPath)) {
          continue;
        }
        final start =
            line.indexOf(observabilityPath) + observabilityPath.length;
        final after = line.substring(start);
        final end = after.indexOf("'");
        final importedFile = end == -1 ? after : after.substring(0, end);

        expect(
          importedFile,
          allowedSeamFile,
          reason:
              '${file.path} may only import the observability seam '
              '($allowedSeamFile), not $importedFile',
        );
      }
    }
  });
}
