import 'package:digital_bank/core/services/observability/observability_provider.dart';
import 'package:digital_bank/features/onboarding/di/onboarding_providers.dart';
import 'package:digital_bank/features/onboarding/presentation/notifiers/onboarding_notifier.dart';
import 'package:digital_bank/features/onboarding/presentation/onboarding_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fake_observability.dart';
import '../../../../support/fake_onboarding_repository.dart';
import '../../../../support/observability_policy.dart';

ProviderContainer _container(
  FakeOnboardingRepository repository, {
  FakeObservability? observability,
}) {
  return ProviderContainer(
    overrides: [
      onboardingRepositoryProvider.overrideWithValue(repository),
      if (observability != null)
        observabilityProvider.overrideWithValue(observability),
    ],
  );
}

void main() {
  group('OnboardingNotifier', () {
    test('ONB-U-005 build starts in the initial state', () {
      final container = _container(FakeOnboardingRepository());
      addTearDown(container.dispose);

      expect(container.read(onboardingProvider), isA<OnboardingInitial>());
    });

    test('ONB-U-005 resolve() Success(false) -> OnboardingRequired', () async {
      final container = _container(FakeOnboardingRepository());
      addTearDown(container.dispose);

      await container.read(onboardingProvider.notifier).resolve();

      expect(container.read(onboardingProvider), isA<OnboardingRequired>());
    });

    test('ONB-U-005 resolve() Success(true) -> OnboardingCompleted', () async {
      final container = _container(FakeOnboardingRepository(completed: true));
      addTearDown(container.dispose);

      await container.read(onboardingProvider.notifier).resolve();

      expect(container.read(onboardingProvider), isA<OnboardingCompleted>());
    });

    test('ONB-U-007 resolve() Failure -> OnboardingRequired + reports', () async {
      final observability = FakeObservability();
      final container = _container(
        FakeOnboardingRepository(readFailure: true),
        observability: observability,
      );
      addTearDown(container.dispose);

      await container.read(onboardingProvider.notifier).resolve();

      expect(container.read(onboardingProvider), isA<OnboardingRequired>());
      expect(observability.events.single.name, 'onboarding_storage_failed');
      expectEventsRespectSensitiveDataPolicy(observability.events);
    });

    test('ONB-U-006 complete() Success -> OnboardingCompleted', () async {
      final repository = FakeOnboardingRepository();
      final container = _container(repository);
      addTearDown(container.dispose);

      await container.read(onboardingProvider.notifier).complete();

      expect(repository.completeCalls, 1);
      expect(container.read(onboardingProvider), isA<OnboardingCompleted>());
    });

    test('ONB-U-007 complete() Failure -> OnboardingRequired + reports', () async {
      final observability = FakeObservability();
      final container = _container(
        FakeOnboardingRepository(writeFailure: true),
        observability: observability,
      );
      addTearDown(container.dispose);
      await container.read(onboardingProvider.notifier).resolve();

      await container.read(onboardingProvider.notifier).complete();

      expect(container.read(onboardingProvider), isA<OnboardingRequired>());
      expect(observability.events.single.name, 'onboarding_storage_failed');
      expectEventsRespectSensitiveDataPolicy(observability.events);
    });
  });
}
