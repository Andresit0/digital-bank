import 'package:digital_bank/core/services/observability/noop_observability.dart';
import 'package:digital_bank/shared/observability/observability_event.dart';
import 'package:digital_bank/shared/observability/observability_severity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoopObservability', () {
    test('OBS-010 report does not throw and has no side effects', () {
      const observability = NoopObservability();

      expect(
        () => observability.report(
          const ObservabilityEvent(
            name: 'app_started',
            severity: ObservabilitySeverity.info,
          ),
        ),
        returnsNormally,
      );
    });
  });
}
