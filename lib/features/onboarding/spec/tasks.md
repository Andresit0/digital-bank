# Tasks: Onboarding

Each implementation step follows RED to GREEN to REFACTOR.

1. SPEC (commit: docs(onboarding): define onboarding policy)
   - Add the six specification files under lib/features/onboarding/spec/.
   - Add docs/architecture/adr/010-local-persistence.md and
     docs/architecture/pr21-onboarding.md (draft).
   - Update requirements traceability for REQ-001 (onboarding) as a target.
   - Do NOT touch code, pubspec, README, or CI.

2. CONTRACTS AND TESTS (commit: test(onboarding): define onboarding contracts)
   - Add the RED tests and fakes; no plugin dependency yet; deterministic.

3. CORE STORAGE (commit: feat(onboarding): add KeyValueStore storage seam)
   - Add `shared_preferences`; implement `KeyValueStore` and
     `SharedPreferencesKeyValueStore` (SharedPreferencesAsync) and its provider.
   - RED to GREEN to REFACTOR.

4. DOMAIN AND INFRASTRUCTURE (commit: feat(onboarding): add repository and data source)
   - Implement `OnboardingRepository` + impl and `OnboardingLocalDataSource`.
   - RED to GREEN to REFACTOR.

5. PRESENTATION (commit: feat(onboarding): add onboarding state and screen)
   - Implement `OnboardingState`, `OnboardingNotifier`, `onboardingProvider`,
     the screen, steps, Next/Skip, and progress indicator.
   - Report storage failures through IObservability without sensitive data.
   - RED to GREEN to REFACTOR.

6. ROUTING (commit: feat(onboarding): gate startup routing on onboarding completion)
   - Add AppRoute.onboarding ('/onboarding'); resolve completion at bootstrap;
     keep the redirect synchronous; extend the refresh listenable; logout -> login.
   - RED to GREEN to REFACTOR.

7. VERIFICATION
   - dart format . ; flutter analyze ; flutter test ;
     flutter test integration_test/onboarding/onboarding_flow_test.dart ;
     git diff --check.

8. TRACEABILITY AND DOCUMENTATION
   (commit: docs(onboarding): finalize onboarding documentation)
   - Update README (Project Status, milestones, testing, docs list),
     docs/architecture/README.md, and requirements-traceability.md with evidence.

## Definition of Done

- `flutter analyze` clean.
- `flutter test` green (unit + widget + integration-style).
- Deterministic onboarding E2E green.
- ONB scenarios and E2E-ONB-001 covered.
- `git diff --check` clean.
