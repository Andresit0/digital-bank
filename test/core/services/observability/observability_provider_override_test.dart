import 'package:digital_bank/core/services/observability/observability_provider.dart';
import 'package:digital_bank/shared/observability/observability_event.dart';
import 'package:digital_bank/shared/observability/observability_severity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_observability.dart';

void main() {
  group('observabilityProvider wiring', () {
    test('can be overridden with a FakeObservability', () {
      final fake = FakeObservability();
      final container = ProviderContainer(
        overrides: [observabilityProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      final observability = container.read(observabilityProvider);

      expect(observability, same(fake));
    });

    test('overridden provider receives reported events', () {
      final fake = FakeObservability();
      final container = ProviderContainer(
        overrides: [observabilityProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      container
          .read(observabilityProvider)
          .report(
            const ObservabilityEvent(
              name: 'app_started',
              severity: ObservabilitySeverity.info,
            ),
          );

      expect(fake.events, hasLength(1));
      expect(fake.events.single.name, 'app_started');
    });
  });
}
