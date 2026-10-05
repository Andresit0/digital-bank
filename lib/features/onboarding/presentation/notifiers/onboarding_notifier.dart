import 'package:digital_bank/core/services/observability/observability_provider.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/observability/observability_event.dart';
import 'package:digital_bank/shared/observability/observability_severity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/onboarding_providers.dart';
import '../onboarding_state.dart';

final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingInitial();

  Future<void> resolve() async {
    final result = await ref.read(onboardingRepositoryProvider).isCompleted();

    result.when(
      success: (completed) {
        state = completed
            ? const OnboardingCompleted()
            : const OnboardingRequired();
      },
      failure: (error) {
        ref.read(observabilityProvider).report(_storageFailedEvent(error));
        state = const OnboardingRequired();
      },
    );
  }

  Future<void> complete() async {
    final result = await ref.read(onboardingRepositoryProvider).complete();

    result.when(
      success: (_) => state = const OnboardingCompleted(),
      failure: (error) {
        ref.read(observabilityProvider).report(_storageFailedEvent(error));
        state = const OnboardingRequired();
      },
    );
  }

  ObservabilityEvent _storageFailedEvent(AppError error) {
    return ObservabilityEvent(
      name: 'onboarding_storage_failed',
      severity: ObservabilitySeverity.warning,
      metadata: <String, Object?>{'errorType': error.runtimeType.toString()},
    );
  }
}
