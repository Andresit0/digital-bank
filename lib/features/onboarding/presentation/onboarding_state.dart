sealed class OnboardingState {
  const OnboardingState();
}

final class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

final class OnboardingRequired extends OnboardingState {
  const OnboardingRequired();
}

final class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}
