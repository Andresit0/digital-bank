# Feature: Onboarding

## Purpose

Present a brief, controlled onboarding experience to a new customer before
authentication and remember that it was completed, so it is not shown again on
subsequent launches. The feature integrates with the existing router and the
existing authentication flow without altering Login -> Home.

## Scope

- First-run experience before authentication.
- Multiple onboarding steps explaining the purpose of the application.
- Forward navigation (Next) and Skip.
- Progress indicator.
- Explicit completion of onboarding.
- Minimal local persistence of `onboarding_completed`.
- Integration with existing routing (Onboarding -> Login) and session (logout -> Login).
- Local persistence isolated behind `KeyValueStore`.

## Out of Scope

- Registration.
- Password recovery.
- Biometrics.
- Complex interactive tutorials.
- Profile-based personalization.
- Onboarding-specific backend.
- CMS.
- Onboarding-specific analytics.
- Feature flags.
- Remote configuration.
- Cross-device synchronization of onboarding state.

## Actors

- New customer (onboarding not completed).
- Returning customer (onboarding completed).

## Functional Requirements

- ONB-001 A new customer sees onboarding before authentication.
- ONB-002 Onboarding explains the purpose of the application across multiple steps.
- ONB-003 The customer can advance with Next and skip where applicable.
- ONB-004 Onboarding shows progress.
- ONB-005 The customer can complete onboarding.
- ONB-006 Completing onboarding persists `onboarding_completed`.
- ONB-007 A completed onboarding is not shown again on a subsequent launch.
- ONB-008 Completing onboarding leads to the existing authentication flow (login).
- ONB-009 Login -> Home remains intact; logout returns to login, not onboarding.
- ONB-010 Completion survives logout and subsequent application launches while the persisted preference remains available.
- ONB-011 Onboarding depends on the `KeyValueStore` contract, never on the storage plugin.
- ONB-012 Onboarding controls expose semantic labels, respect text scaling, maintain accessible contrast, and use appropriate touch targets.

## States

```text
OnboardingInitial
   |
   v
OnboardingRequired -- complete() --> OnboardingCompleted
```

`OnboardingInitial` is the resting state before the completion status is resolved
at bootstrap. `OnboardingRequired` is presented to a new customer.
`OnboardingCompleted` routes to login.

## Business Rules

- Onboarding is presented until the persisted completion state is set to true.
- Completing onboarding persists the flag before navigating to login.
- Skipping completes onboarding (Skip is equivalent to finishing early).
- Logout does not reset onboarding completion.

## Security

- No sensitive data is stored; only a boolean `onboarding_completed`.
- No credentials or tokens are involved.
- Storage access is isolated behind `KeyValueStore`.

## Dependencies

- `shared_preferences` (new), imported only by the `core/storage` adapter.
- `KeyValueStore` from `core/storage`.
- Riverpod for state management and DI; go_router for routing.
- Existing auth feature and router.

## Traceability

- REQ-001 Customer onboarding and authentication (onboarding portion).
- REQ-009 Loading/recovery behavior — bootstrap exposes an explicit initial/resolving state while onboarding completion is loaded.
- REQ-010 Unit tests.
- REQ-011 Widget tests.
- REQ-012 Critical end-to-end flow.
- REQ-023 Usable and coherent experience.
- REQ-025 Accessible UI.
- SEC-002 Sensitive data protection (nothing sensitive persisted).

## Acceptance Criteria

- ONB-001 A new customer sees onboarding before login.
- ONB-002 Onboarding presents multiple steps explaining the application purpose.
- ONB-003 Next advances and Skip completes.
- ONB-004 Progress is represented.
- ONB-005 Onboarding can be completed.
- ONB-006 Completion persists `onboarding_completed`.
- ONB-007 A completed onboarding is not shown again on the next launch.
- ONB-008 Completion navigates to login.
- ONB-009 Login -> Home is intact; logout returns to login.
- ONB-010 Completion survives logout and subsequent launches while the persisted preference remains available.
- ONB-011 The feature does not import the storage plugin.
- ONB-012 Accessibility requirements are satisfied for onboarding controls.
