import 'package:digital_bank/shared/observability/observability_event.dart';
import 'package:digital_bank/shared/observability/observability_severity.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_observability.dart';

void main() {
  group('FakeObservability', () {
    test('captures reported events', () {
      final observability = FakeObservability();

      observability.report(
        const ObservabilityEvent(
          name: 'app_started',
          severity: ObservabilitySeverity.info,
        ),
      );

      expect(observability.events, hasLength(1));
    });

    test('preserves name, severity, metadata, and timestamp', () {
      final observability = FakeObservability();
      final timestamp = DateTime.utc(2026, 10, 4);

      observability.report(
        ObservabilityEvent(
          name: 'app_startup_failed',
          severity: ObservabilitySeverity.fatal,
          metadata: const <String, Object?>{'errorType': 'UnexpectedError'},
          timestamp: timestamp,
        ),
      );

      final event = observability.events.single;
      expect(event.name, 'app_startup_failed');
      expect(event.severity, ObservabilitySeverity.fatal);
      expect(event.metadata, <String, Object?>{'errorType': 'UnexpectedError'});
      expect(event.timestamp, timestamp);
    });

    test('preserves insertion order across multiple events', () {
      final observability = FakeObservability();

      observability.report(
        const ObservabilityEvent(
          name: 'app_started',
          severity: ObservabilitySeverity.info,
        ),
      );
      observability.report(
        const ObservabilityEvent(
          name: 'app_error',
          severity: ObservabilitySeverity.error,
        ),
      );

      expect(observability.events.map((event) => event.name).toList(), <String>[
        'app_started',
        'app_error',
      ]);
    });
  });
}
