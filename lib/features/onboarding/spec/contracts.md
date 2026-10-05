# Contracts: Onboarding

## Internal Boundary

```text
OnboardingScreen
    |
    v
OnboardingNotifier        (Result -> state + observability)
    |
    v
OnboardingRepository      (guard -> Result<T>, no observability)
    |
    v
OnboardingLocalDataSource (raw Future<bool> / Future<void>)
    |
    v
KeyValueStore
    |
    v
SharedPreferencesKeyValueStore -> SharedPreferencesAsync
```

Dependency direction:

```text
presentation   -> domain
domain         -> shared/error (Result, AppError)
infrastructure -> domain
infrastructure -> core/storage
```

The feature never imports `shared_preferences`.

## Storage Contract (core/storage, generic)

```dart
abstract interface class KeyValueStore {
  Future<bool?> getBool(String key);
  Future<void> setBool(String key, bool value);
}
```

Owned by `core/storage`; it contains no onboarding knowledge.

## Key

`onboarding_completed` is a private constant of `OnboardingLocalDataSource`, not
part of global configuration.

## OnboardingLocalDataSource

```dart
abstract interface class OnboardingLocalDataSource {
  Future<bool> isCompleted();
  Future<void> markCompleted();
}
```

`isCompleted()` maps `getBool('onboarding_completed')` with `null -> false`.
`markCompleted()` calls `setBool('onboarding_completed', true)`.

The data source returns raw values; it does not guard or map errors.

## OnboardingRepository

```dart
abstract interface class OnboardingRepository {
  Future<Result<bool>> isCompleted();
  Future<Result<void>> complete();
}
```

`OnboardingRepositoryImpl` wraps the data source with `guard(...)` and exposes
`Result`: a read failure becomes `Failure(AppError)` (the notifier treats it as
not completed); a write failure becomes `Failure(AppError)` (the notifier does
not mark completion). The repository is pure: it does not report observability.

## Routing Contract

```text
bootstrap /
    not completed                 -> /onboarding
    completed + not authenticated -> /login
    authenticated                 -> /home

/onboarding -- complete() --> /login
authenticated -> unauthenticated (logout) -> /login
```

The redirect remains synchronous. A refresh listenable reflects the resolved
onboarding status plus the auth state, as auth already does.

## State Exposure

`OnboardingNotifier` exposes `OnboardingState`; the router observes completion
through a refresh listenable. The router instance is not rebuilt on changes.

## Observability

`onboarding_storage_failed` is reported by `OnboardingNotifier` through
`IObservability` (ADR-009) when the repository returns a failure, with minimal
non-sensitive metadata (`errorType`). This follows the project pattern where
repositories return `Result` and notifiers decide UI state and report
observability. No `onboarding_started`, `onboarding_skipped`, or
`onboarding_completed` events are introduced.
