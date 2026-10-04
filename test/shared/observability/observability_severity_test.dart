import 'package:digital_bank/shared/observability/observability_severity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ObservabilitySeverity', () {
    test('OBS-003 exposes debug, info, warning, error, fatal', () {
      expect(ObservabilitySeverity.values, hasLength(5));
      expect(
        ObservabilitySeverity.values.map((severity) => severity.name).toList(),
        <String>['debug', 'info', 'warning', 'error', 'fatal'],
      );
    });
  });
}
