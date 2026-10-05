# Tests: Onboarding

Tests derive from the specification scenarios, not from the implementation.

## Requirement to Scenario to Test

| Requirement | Scenario | Test Level |
|---|---|---|
| ONB-001/007 | First-run vs returning launch | unit, routing |
| ONB-002/003/004 | Steps, Next, Skip, progress | widget |
| ONB-005/006 | Completion persists | unit, widget |
| ONB-008 | Onboarding -> login | routing, E2E |
| ONB-009 | Login -> Home intact; logout -> login | routing |
| ONB-010 | Survives logout/restart | unit, routing |
| ONB-011 | No plugin import in the feature | architecture |
| ONB-012 | Accessibility of controls | widget |

## Unit Scenarios

| ID | Scenario |
|---|---|
| ONB-U-001 | isCompleted returns true when persisted true |
| ONB-U-002 | isCompleted returns false when absent |
| ONB-U-003 | complete persists true |
| ONB-U-004 | data source maps null to false |
| ONB-U-005 | notifier resolves required/completed |
| ONB-U-006 | notifier complete() sets completed and persists |
| ONB-U-007 | storage failure does not crash and is reported |

## Widget Scenarios

| ID | Scenario |
|---|---|
| ONB-W-001 | A new customer sees onboarding |
| ONB-W-002 | Next advances to the next step |
| ONB-W-003 | The progress indicator reflects the current step |
| ONB-W-004 | Skip completes onboarding |
| ONB-W-005 | Completing the last step completes onboarding |
| ONB-W-006 | Onboarding controls expose semantic labels and accessible targets |

## Routing Scenarios

| ID | Scenario |
|---|---|
| ONB-R-001 | bootstrap resolves to onboarding when not completed |
| ONB-R-002 | bootstrap resolves to login when completed and unauthenticated |
| ONB-R-003 | an authenticated customer reaches /home |
| ONB-R-004 | logout returns to login, not onboarding |

## E2E Scenarios

| ID | Scenario |
|---|---|
| E2E-ONB-001 | onboarding -> login -> Home |

## Test Files

```text
test/core/storage/key_value_store_test.dart
test/core/storage/shared_preferences_key_value_store_test.dart
test/features/onboarding/domain/repositories/onboarding_repository_test.dart
test/features/onboarding/infrastructure/datasources/onboarding_local_data_source_test.dart
test/features/onboarding/infrastructure/repositories/onboarding_repository_impl_test.dart
test/features/onboarding/presentation/notifiers/onboarding_notifier_test.dart
test/features/onboarding/presentation/screens/onboarding_screen_test.dart
test/features/onboarding/routing/onboarding_routing_test.dart
test/support/fake_onboarding_repository.dart
test/architecture/onboarding_storage_dependency_test.dart
integration_test/onboarding/onboarding_flow_test.dart
```

## Architecture

- A new architecture test ensures `features/onboarding` does not import
  `package:shared_preferences`; only `core/storage` may.
- Extends the pattern of `test/architecture/observability_dependency_test.dart`.

## Error Mapping Ownership

- `OnboardingLocalDataSource` maps a missing value (`null`) to `false` and
  returns raw values without guarding.
- `OnboardingRepositoryImpl` applies `guard(...)` at the data boundary and
  exposes `Result`: `Failure(AppError)` on a read or write failure. It is pure
  and does not report observability.
- `OnboardingNotifier` consumes the `Result`, maps it to `OnboardingState`, and
  reports `onboarding_storage_failed` on failure; it never exposes sensitive
  data.

## Behavior Coverage

- A customer whose persisted onboarding state is incomplete sees onboarding; a
  completed persisted state goes to login.
- Next/Skip/progress behave as specified.
- Completion persists before navigating to login.
- Logout and restart do not show onboarding again.
- Storage failures never crash and never persist sensitive data.
