import 'package:digital_bank/core/services/observability/noop_observability.dart';
import 'package:digital_bank/core/services/observability/observability_provider.dart';
import 'package:digital_bank/shared/interfaces/i_observability.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('observabilityProvider', () {
    test('OBS-011 resolves an IObservability', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final observability = container.read(observabilityProvider);

      expect(observability, isA<IObservability>());
    });

    test('OBS-011 defaults to NoopObservability', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(observabilityProvider), isA<NoopObservability>());
    });
  });
}
