# Tests: Movements

Tests derive from the specification scenarios, not from the implementation.
Unit, widget, integration-style, and E2E scenarios are defined before
implementation.

## Requirement to Scenario to Test

| Requirement | Scenario | Test Level |
|---|---|---|
| MOV-001 | Movements of the selected account are displayed | unit, integration-style, widget, E2E |
| MOV-002 | Credit and debit distinguishable | unit, widget |
| MOV-003 | Amount and currency displayed | unit, widget |
| MOV-004 | Description and occurredAt displayed | unit, widget |
| MOV-005 | Explicit states | integration-style, widget |
| MOV-006 | Detail from loaded list without HTTP | widget, E2E |
| MOV-007 | Only the customer's movements | integration-style |

## Unit Scenarios

| ID | Scenario |
|---|---|
| UNIT-MOV-001 | Movement exposes its fields and value semantics |
| UNIT-MOV-002 | MovementType exposes credit and debit |

## Repository Scenarios

| ID | Scenario |
|---|---|
| MOV-REPO-001 | Success returns Success(List<Movement>) |
| MOV-REPO-002 | 401 returns Failure(ApiError 401) |
| MOV-REPO-003 | 5xx returns Failure(ApiError 5xx) |
| MOV-REPO-004 | Transport failure returns Failure(NetworkError) |
| MOV-REPO-005 | Invalid payload returns Failure(ApiError 200) |

## Widget Scenarios

| ID | Scenario |
|---|---|
| WID-MOV-001 | Loading state |
| WID-MOV-002 | Movement list rendered with type, amount, currency, description, date |
| WID-MOV-003 | Empty state |
| WID-MOV-004 | Error state |
| WID-MOV-005 | Detail rendered from the loaded movement without a new request |

## Integration-Style Scenarios (CI)

| ID | Scenario |
|---|---|
| INT-MOV-001 | Loads movements successfully for the accountId |
| INT-MOV-002 | Server error (5xx) maps to ApiError |
| INT-MOV-003 | Transport failure maps to NetworkError |
| INT-MOV-004 | Empty response maps to Success([]) |
| OBS-INT-MOV-WIRING-001 | Load failure reports movements_load_failed through the seam |
| SEC-OBS-001 | No prohibited metadata keys in reported events |
| SEC-OBS-002 | No sensitive values in reported events |

## E2E Scenarios

| ID | Scenario |
|---|---|
| E2E-MOV-001 | Login -> Home -> Accounts -> Movements (account card tap) |
| E2E-MOV-002 | Movements loaded -> Movement Detail (/movements/:id) -> back to the list; list remains available and no additional HTTP request is made |

`E2E-MOV-002` protects the list -> detail -> back cycle: opening a movement
detail reuses the loaded `Movement`, back navigation keeps the movements list
and its `accountId` context, and no second request to
`GET /accounts/{accountId}/movements` is made.

## Test Files

```text
test/features/movements/
  domain/entities/movement_test.dart
  domain/repositories/movements_repository_test.dart
  infrastructure/models/movement_model_test.dart
  infrastructure/datasources/movements_remote_data_source_test.dart
  infrastructure/repositories/movements_repository_impl_test.dart
  presentation/notifiers/movements_notifier_test.dart
  presentation/screens/movements_screen_test.dart
  presentation/screens/movement_detail_screen_test.dart
  integration/movements_flow_test.dart

integration_test/
  movements/movements_flow_test.dart
```

## Error Mapping Ownership

- `MovementsRemoteDataSource` tests verify `HttpClient.get(...)` to
  `MovementModel.fromJson(...)`. They do not assert `AppError` outcomes.
- `MovementsRepositoryImpl` tests verify the infrastructure-to-domain mapping
  through `guard()`:
  - `401` produces `Failure(ApiError 401)`.
  - `5xx` produces `Failure(ApiError 5xx)`.
  - `NetworkException` without status produces `Failure(NetworkError)`.
  - an invalid payload with status `200` produces `Failure(ApiError 200)`.
  - a non-empty `200` produces `Success(List<Movement>)`.
  - an empty `200` produces `Success([])`.

## Behavior Coverage

- Successful load produces the loaded state.
- Empty response produces the empty state, not a failure.
- Failure produces `MovementsFailure` with the mapped `AppError`.
- Loading is represented.
- The notifier requires `accountId` and never infers a selected account.
- The detail consumes a `Movement` from the loaded list and performs no HTTP request.
- The notifier reports failures through `IObservability` without sensitive data.
- Ownership of `accountId` is enforced by the authenticated backend; the client
  maps a `403` through the same generic boundary as other `ApiError` outcomes and
  does not define a dedicated scenario for it in this feature.

## Integration-Style Note

`INT-MOV-*` are integration-style tests: they exercise the real
provider/repository/datasource wiring against an HTTP double. They are not
integration against a real backend.
