# Tests: Authentication

Tests derive from the specification scenarios, not from the implementation.

## Requirement to Scenario to Test

| Requirement | Scenario | Test Level |
|---|---|---|
| AUTH-001 | Successful authentication | datasource, repository, notifier, widget |
| AUTH-002 | Credentials sent via HttpClient | datasource |
| AUTH-003 | Session created | repository, notifier |
| AUTH-004 | Invalid credentials | repository, notifier, widget |
| AUTH-005 | Network failure | repository, notifier, widget |
| AUTH-006 | Explicit states | notifier, widget |
| AUTH-007 | Protected routing | routing |
| AUTH-008 | Logout | notifier, widget, routing |

## Test Files

```text
test/features/auth/
  domain/repositories/auth_repository_test.dart
  infrastructure/datasources/auth_remote_data_source_test.dart
  infrastructure/models/auth_response_model_test.dart
  infrastructure/repositories/auth_repository_impl_test.dart
  presentation/notifiers/auth_notifier_test.dart
  presentation/screens/login_screen_test.dart
  routing/auth_routing_test.dart
```

## AUTH-002 Evidence

- The `AuthRemoteDataSource` test verifies delegation to `HttpClient` using a
  fake or test `HttpClient`.

Architectural verification, performed separately from the unit test, ensures that
`features/auth` does not import `package:dio`. This is an architecture check, not
a functional behavior asserted inside a unit test.

## Error Mapping Ownership

- `AuthRemoteDataSource` tests verify `HttpClient.post(...)` to
  `AuthResponseModel.fromJson(...)`. They do not assert `AppError` outcomes.
- `AuthRepositoryImpl` tests verify the infrastructure-to-domain mapping through
  `guard()`:
  - `401` produces `Failure(ApiError 401)`.
  - `5xx` produces `Failure(ApiError 5xx)`.
  - `NetworkException` without status produces `Failure(NetworkError)`.
  - `200` produces `Success(AuthSession)`.

## Behavior Coverage

- Successful authentication produces an authenticated state.
- Invalid credentials produce `Failure(ApiError 401)` without a session.
- Network failure produces `Failure(NetworkError)` and remains recoverable.
- Loading is represented and duplicate submissions are prevented while loading.
- The protected area requires authentication and redirects when absent.
- Logout clears the session and returns to login.
- The notifier reports failures through `IObservability` without sensitive data.

## Authentication Test Scenarios

```text
Authentication test scenarios
  INT-AUTH-001 .. INT-AUTH-006
        |
        +-- Integration-style (CI)
        |     test/features/auth/integration/authentication_flow_test.dart
        |
        +-- E2E
              integration_test/auth/authentication_flow_test.dart
```

`INT-AUTH-001 .. INT-AUTH-006` identify the scenarios. They are reused across
both test layers; the two files are not the same test. Each layer exercises the
same functional contract through a different transport.

| ID | Scenario |
|---|---|
| INT-AUTH-001 | Successful login |
| INT-AUTH-002 | Invalid credentials |
| INT-AUTH-003 | Server error |
| INT-AUTH-004 | Transport failure |
| INT-AUTH-005 | Logout |
| INT-AUTH-006 | Protected route without session |

### Integration-style (CI)

- File: `test/features/auth/integration/authentication_flow_test.dart`.
- Scenarios: INT-AUTH-001 .. INT-AUTH-006.
- Execution: `flutter test`.
- `DioHttpClient` and `Dio` are real.
- Only the transport is substituted through a deterministic `HttpClientAdapter`.
- No real network.
- `connection error` corresponds only to this layer.

### E2E

- File: `integration_test/auth/authentication_flow_test.dart`.
- Scenarios: INT-AUTH-001 .. INT-AUTH-006.
- Binding: `IntegrationTestWidgetsFlutterBinding`.
- Device: iOS Simulator.
- Real `HttpServer` on `127.0.0.1`.
- `Dio` is real; HTTP is real within the E2E environment.
- INT-AUTH-004 uses a closed port.

Both layers validate the same functional contract but exercise different
transports; they are not equivalent. Neither constitutes evidence of integration
with a real backend.
