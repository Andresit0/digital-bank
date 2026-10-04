import 'package:digital_bank/shared/observability/observability_event.dart';
import 'package:digital_bank/shared/observability/observability_severity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_observability.dart';
import '../../../support/observability_policy.dart';

void main() {
  group('observability security policy', () {
    test('SEC-OBS-001 compliant captured events pass the metadata policy', () {
      final observability = FakeObservability();

      observability.report(
        const ObservabilityEvent(
          name: 'auth_login_failed',
          severity: ObservabilitySeverity.warning,
          metadata: <String, Object?>{
            'errorType': 'ApiError',
            'statusCode': 401,
          },
        ),
      );

      expectEventsRespectSensitiveDataPolicy(observability.events);
    });

    test('SEC-OBS-001 the policy detects a prohibited metadata key', () {
      const event = ObservabilityEvent(
        name: 'auth_login_failed',
        severity: ObservabilitySeverity.warning,
        metadata: <String, Object?>{'password': 'value'},
      );

      expect(
        () => expectEventsRespectSensitiveDataPolicy(const [event]),
        throwsA(isA<TestFailure>()),
      );
    });

    test('SEC-OBS-002 the policy detects a prohibited sensitive value', () {
      const event = ObservabilityEvent(
        name: 'network_failure',
        severity: ObservabilitySeverity.warning,
        metadata: <String, Object?>{'endpoint': 'customer@example.com'},
      );

      expect(
        () => expectEventsRespectSensitiveDataPolicy(const [event]),
        throwsA(isA<TestFailure>()),
      );
    });

    test('SEC-OBS-002 the event model adds no metadata of its own', () {
      const event = ObservabilityEvent(
        name: 'app_error',
        severity: ObservabilitySeverity.error,
        metadata: <String, Object?>{'errorType': 'UnexpectedError'},
      );

      expect(event.metadata, hasLength(1));
      expect(event.metadata.containsKey('errorType'), isTrue);
    });
  });
}
