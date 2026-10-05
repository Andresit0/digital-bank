# Domain: Onboarding

## Entities

None. The only domain behavior is the persisted completion state.

## Repository Contract

```dart
abstract interface class OnboardingRepository {
  Future<Result<bool>> isCompleted();
  Future<Result<void>> complete();
}
```

Semantics:

- `isCompleted()` returns `Success(true)` when the persisted value is `true`,
  and `Success(false)` when the value is absent or `false`.
- `complete()` returns `Success(null)` after persisting `true`.
- A storage failure is carried explicitly as `Failure(AppError)`, produced by
  `guard(...)` at the repository boundary (the shared error pattern used by the
  other repositories).

No use cases are introduced because the only domain behavior is the completion
state.

## Presentation State

```text
sealed class OnboardingState
  OnboardingInitial
  OnboardingRequired
  OnboardingCompleted
```

## Errors

The feature reuses the shared error model (`Result` and `AppError` from
`shared/error`) and defines no error hierarchy of its own. The repository applies
`guard(...)` at the data boundary and returns `Failure(AppError)`.

The repository does not report observability. The notifier consumes the
`Result`: a read failure marks onboarding as required and reports
`onboarding_storage_failed` through `IObservability`; a write failure leaves the
state unchanged (required) and reports the same event, so the UI never navigates
to login before persistence succeeds. No sensitive data is reported.

## Rules

- The domain does not import Flutter, `shared_preferences`, or `core/storage`.
- The domain depends on `shared/error` (`Result`, `AppError`).
