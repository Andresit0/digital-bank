# Tests: Accounts

Tests derive from the specification scenarios, not from the implementation.
Unit, widget, integration, and E2E scenarios are defined before implementation.

## Requirement to Scenario to Test

| Requirement | Scenario | Test Level |
|---|---|---|
| ACC-001 | Customer sees accounts | unit, integration, widget, E2E |
| ACC-002 | Savings and checking distinguishable | unit, widget |
| ACC-003 | Masked account number | unit, widget |
| ACC-004 | Available balance displayed | unit, integration, widget |
| ACC-005 | Explicit states | integration, widget |
| ACC-006 | Empty is not an error | integration, widget |
| ACC-007 | Only customer's accounts | integration |

## Unit Scenarios

| ID | Scenario |
|---|---|
| ACC-001 | Account exposes its fields and value semantics |

## Integration Scenarios

| ID | Scenario |
|---|---|
| INT-ACC-001 | Accounts load successfully |
| INT-ACC-002 | Server error (5xx) |
| INT-ACC-003 | Network / transport failure |
| INT-ACC-004 | Empty accounts response |

## Widget Scenarios

| ID | Scenario |
|---|---|
| WID-ACC-001 | Loading state |
| WID-ACC-002 | Account cards rendered |
| WID-ACC-003 | Error state |

## E2E Scenarios

| ID | Scenario |
|---|---|
| E2E-ACC-001 | Login -> Home -> Accounts |
| E2E-ACC-002 | Authenticated customer sees account balances |

## Test Files

```text
test/features/accounts/
  domain/entities/account_test.dart
  infrastructure/datasources/accounts_remote_data_source_test.dart
  infrastructure/models/account_model_test.dart
  infrastructure/repositories/accounts_repository_impl_test.dart
  presentation/notifiers/accounts_notifier_test.dart
  presentation/screens/accounts_screen_test.dart
  integration/accounts_flow_test.dart

integration_test/
  accounts/accounts_flow_test.dart
```

## Error Mapping Ownership

- `AccountsRemoteDataSource` tests verify `HttpClient.get(...)` to
  `AccountModel.fromJson(...)`. They do not assert `AppError` outcomes.
- `AccountsRepositoryImpl` tests verify the infrastructure-to-domain mapping
  through `guard()`:
  - `401` produces `Failure(ApiError 401)`.
  - `5xx` produces `Failure(ApiError 5xx)`.
  - `NetworkException` without status produces `Failure(NetworkError)`.
  - an invalid payload with status `200` produces `Failure(ApiError 200)`.
  - a non-empty `200` produces `Success(List<Account>)`.
  - an empty `200` produces `Success([])`.

## Behavior Coverage

- Successful load produces the loaded state.
- Empty response produces the empty state, not a failure.
- Failure produces `AccountsFailure` with the mapped `AppError`.
- Loading is represented.
- Only the authenticated customer's accounts are represented.
- The notifier reports failures through `IObservability` without sensitive data.
