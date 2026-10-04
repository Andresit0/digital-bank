import 'package:digital_bank/shared/observability/observability_event.dart';
import 'package:digital_bank/shared/observability/observability_severity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ObservabilityEvent', () {
    test('OBS-001 exposes name, severity, and metadata', () {
      const event = ObservabilityEvent(
        name: 'app_started',
        severity: ObservabilitySeverity.info,
        metadata: <String, Object?>{'feature': 'app'},
      );

      expect(event.name, 'app_started');
      expect(event.severity, ObservabilitySeverity.info);
      expect(event.metadata, <String, Object?>{'feature': 'app'});
    });

    test('OBS-002 metadata defaults to empty and timestamp is optional', () {
      const event = ObservabilityEvent(
        name: 'auth_logout',
        severity: ObservabilitySeverity.info,
      );

      expect(event.metadata, isEmpty);
      expect(event.timestamp, isNull);
    });

    test('OBS-002 timestamp can be provided by a producer', () {
      final timestamp = DateTime.utc(2026, 10, 4);
      final event = ObservabilityEvent(
        name: 'app_started',
        severity: ObservabilitySeverity.info,
        timestamp: timestamp,
      );

      expect(event.timestamp, timestamp);
    });
  });
}
