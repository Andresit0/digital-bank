# PR12 — Error Handling and Development Logging

## Document Information

| Field | Value |
|---|---|
| Project | Digital Financial Platform — Flutter Technical Assessment |
| Document | PR12 Specification — Error Handling and Development Logging |
| Status | Frozen (approved) |
| Related ADR | ADR-003 (Networking and Resilience Boundaries), ADR-009 (Observability and Monitoring, planned) |
| Related Requirements | REQ-009, REQ-013, REQ-022, SEC-005 |
| Scope | Cross-cutting (shared + core), feature migration limited to Auth and Accounts |

---

## 1. Purpose

PR12 introduces a transversal, explicit error model and a development logging seam so that:

- transport failures never leak into domain or presentation;
- features consume a single error vocabulary;
- failures can be observed during development without coupling features to a concrete observability provider;
- PR14 can attach a production observability provider (Crashlytics/Firebase/Sentry) without changes in Auth, Accounts, or future features.

This document is the bridge:

```text
ADR-003 (Error Handling boundary)
        ↓
PR12 (Error model + ILogger seam)
        ↓
ADR-009 (Observability and Monitoring)
```

---

## 2. Frozen Architectural Decisions

| ID | Decision |
|---|---|
| D1 | Single error vocabulary: `Result<T>` → `Success<T>` / `Failure<T>` → `AppError`. |
| D2 | `AuthError` and `AccountsError` are removed. State carries `AppError`. |
| D3 | `NetworkException` moves to `lib/shared/exceptions/network_exception.dart`. |
| D4 | `guard()` lives in `shared/error` and maps `NetworkException` to `AppError`. |
| D5 | `ILogger` lives in `shared/interfaces`; `DevLogger` and `loggerProvider` live in `core/services/logging`. |
| D6 | Logging happens at the consumption boundary (Notifier), not in datasources or repositories. |
| D7 | Sensitive data is never logged (SEC-005). |

Dependency direction after PR12:

```text
shared
  ↑
core/network
  ↑
features
```

`shared` never depends on `core` or on any feature.

---

## 3. Scope

### In scope

- `AppError` sealed model: `NetworkError`, `TimeoutError`, `ApiError`, `UnexpectedError`.
- `Result<T>` with `Success` and `Failure`.
- `guard()` converting exceptions into `Result.failure`.
- Relocation of `NetworkException` to `shared/exceptions`.
- `ILogger` interface.
- `DevLogger` implementation using `dart:developer`.
- `loggerProvider` via Riverpod.
- Migration of Auth and Accounts to `Result<T>` + `ILogger`.
- Unit tests for the error model and logger.
- Updated feature tests for Auth and Accounts.
- Spec updates for Auth, Accounts, and requirements traceability.

### Out of scope

- Firebase, Crashlytics, Sentry, production observability.
- Analytics, metrics, distributed tracing, full correlation IDs.
- Retry system, cache/offline.
- Movements, personalization, external service, notifications.
- UI redesign beyond error-message mapping.
- New dependencies (only `dart:developer` from the SDK is used).

---

## 4. Error Model Contracts

### 4.1 `lib/shared/error/app_error.dart`

```dart
sealed class AppError {
  const AppError({this.technicalMessage, this.stackTrace});

  final String? technicalMessage;
  final StackTrace? stackTrace;

  bool get isNetworkRelated => false;
  bool get isTransient => false;

  @override
  String toString() => '$runtimeType(technicalMessage: $technicalMessage)';
}

final class NetworkError extends AppError {
  const NetworkError({super.technicalMessage, super.stackTrace});

  @override
  bool get isNetworkRelated => true;

  @override
  bool get isTransient => true;
}

final class TimeoutError extends AppError {
  const TimeoutError({super.technicalMessage, super.stackTrace});

  @override
  bool get isTransient => true;
}

final class ApiError extends AppError {
  const ApiError({this.statusCode, super.technicalMessage, super.stackTrace});

  final int? statusCode;
}

final class UnexpectedError extends AppError {
  const UnexpectedError({super.technicalMessage, super.stackTrace});
}
```

`isNetworkRelated` and `isTransient` are the preparation point for the future resilience strategy (ADR-003, REQ-006..009). They are not consumed for behavior in PR12.

### 4.2 `lib/shared/error/result.dart`

```dart
sealed class Result<T> {
  const Result();

  bool get isSuccess;

  R when<R>({
    required R Function(T data) success,
    required R Function(AppError error) failure,
  });

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppError error) onFailure,
  });
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  bool get isSuccess => true;

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(AppError error) failure,
  }) => success(data);

  @override
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppError error) onFailure,
  }) => onSuccess(data);
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);

  final AppError error;

  @override
  bool get isSuccess => false;

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(AppError error) failure,
  }) => failure(error);

  @override
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppError error) onFailure,
  }) => onFailure(error);
}
```

### 4.3 `lib/shared/exceptions/network_exception.dart`

```dart
class NetworkException implements Exception {
  const NetworkException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;
}
```

This is the relocation of the former `lib/core/network/network_exception.dart`. No behavior changes.

### 4.4 `lib/shared/error/result_guard.dart`

```dart
import 'dart:async' show TimeoutException;

import '../exceptions/network_exception.dart';
import 'app_error.dart';
import 'result.dart';

Future<Result<T>> guard<T>(Future<T> Function() fn) async {
  try {
    return Success(await fn());
  } on NetworkException catch (error, stackTrace) {
    return Failure(_mapNetwork(error, stackTrace));
  } on TimeoutException catch (error, stackTrace) {
    return Failure(
      TimeoutError(technicalMessage: error.message, stackTrace: stackTrace),
    );
  } on Exception catch (error, stackTrace) {
    return Failure(
      UnexpectedError(technicalMessage: '$error', stackTrace: stackTrace),
    );
  }
}

AppError _mapNetwork(NetworkException error, StackTrace stackTrace) {
  final statusCode = error.statusCode;
  if (statusCode == null) {
    return NetworkError(
      technicalMessage: error.message,
      stackTrace: stackTrace,
    );
  }
  return ApiError(
    statusCode: statusCode,
    technicalMessage: error.message,
    stackTrace: stackTrace,
  );
}
```

`Error` (programming errors) is not captured and propagates.

---

## 5. Logging Abstraction Contracts

### 5.1 `lib/shared/interfaces/i_logger.dart`

```dart
abstract interface class ILogger {
  void info(String message, {String? technicalMessage});

  void error(
    String message, {
    Object? technicalMessage,
    StackTrace? stackTrace,
  });
}
```

### 5.2 `lib/core/services/logging/dev_logger.dart`

```dart
import 'dart:developer';

import '../../../shared/interfaces/i_logger.dart';

class DevLogger implements ILogger {
  const DevLogger();

  @override
  void info(String message, {String? technicalMessage}) {
    log(message, name: 'INFO', error: technicalMessage);
  }

  @override
  void error(
    String message, {
    Object? technicalMessage,
    StackTrace? stackTrace,
  }) {
    log(
      message,
      name: 'ERROR',
      error: technicalMessage,
      stackTrace: stackTrace,
    );
  }
}
```

### 5.3 `lib/core/services/logging/logging_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/interfaces/i_logger.dart';
import 'dev_logger.dart';

final loggerProvider = Provider<ILogger>((ref) => const DevLogger());
```

PR14 provides production observability through `IObservability` (composition root) without touching features.

---

## 6. Error Mapping

| Origin (`NetworkException` / SDK) | `AppError` | `classifyUi` (presentation) |
|---|---|---|
| `statusCode == null` | `NetworkError` | recoverable network error |
| `statusCode == 401` | `ApiError(401)` | invalid credentials |
| `statusCode >= 500` | `ApiError(5xx)` | server failure |
| other `statusCode` | `ApiError(status)` | failure |
| `TimeoutException` | `TimeoutError` | timeout |
| other `Exception` | `UnexpectedError` | generic failure |

Mapping is owned by `guard()`. Features do not map transport exceptions.

---

## 7. Data Flow

```text
Dio / HTTP
    ↓
NetworkException
    ↓
guard()
    ↓
Result<T>
 ┌──┴───────┐
 ↓          ↓
Success   Failure
             ↓
          AppError
             ↓
          Notifier
          ↙     ↘
      State     ILogger
                  ↓
              DevLogger
                  ↓
          dart:developer
```

---

## 8. Sensitive Data Rule (SEC-005)

Never logged:

- passwords;
- access tokens or refresh tokens;
- full account numbers;
- sensitive financial data;
- credentials;
- full payloads that may contain sensitive data.

Allowed technical metadata:

```text
[accounts] load failed
error type: network
status: 500
endpoint: GET /accounts
stack trace: ...
```

Log messages use feature-prefixed, human-readable text. Technical detail is passed through `technicalMessage` and `stackTrace`, never through the message string.

---

## 9. Feature Migration

### 9.1 Auth

Contract change:

```text
AuthRepository.login(...)
  before: Future<AuthSession>
  after:  Future<Result<AuthSession>>
```

`AuthRepositoryImpl`:

```dart
@override
Future<Result<AuthSession>> login({
  required String email,
  required String password,
}) => guard(() async {
  final model = await _remoteDataSource.login(
    email: email,
    password: password,
  );
  return AuthSession(accessToken: model.accessToken);
});
```

`AuthState`:

```dart
final class AuthFailure extends AuthState {
  const AuthFailure(this.error);

  final AppError error;
}
```

`AuthNotifier.login` consumption and logging boundary:

```dart
final result = await ref
    .read(authRepositoryProvider)
    .login(email: email, password: password);

result.when(
  success: (session) {
    state = AuthAuthenticated(session);
  },
  failure: (error) {
    ref.read(loggerProvider).error(
      '[auth] authentication failed',
      technicalMessage: error.technicalMessage,
      stackTrace: error.stackTrace,
    );
    state = AuthFailure(error);
  },
);
```

`LoginScreen` derives the message from `AppError`:

```text
error is ApiError && error.statusCode == 401  ->  "Invalid credentials"
otherwise                                     ->  generic message
```

`AuthError` is deleted.

### 9.2 Accounts

Contract change:

```text
AccountsRepository.fetchAccounts()
  before: Future<List<Account>>
  after:  Future<Result<List<Account>>>
```

`AccountsRepositoryImpl` uses `guard`. `AccountsState` uses `AccountsFailure(AppError)`. `AccountsNotifier.load` logs `'[accounts] load failed'` and emits `AccountsFailure(error)`. `AccountsError` is deleted. The existing generic error screen is preserved.

---

## 10. Logging Placement

- Datasources: no logging.
- Repositories: no logging; only `guard()`.
- Use cases: no logging in PR12.
- Notifiers: single logging boundary on failure.
- Expected argument map:

```text
logger.error(message, {technicalMessage, stackTrace})
```

---

## 11. TDD Test Scenarios

Tests are written before implementation (RED → GREEN → REFACTOR).

### 11.1 New unit tests

`test/shared/error/result_test.dart`

```text
RES-001 Success exposes data and isSuccess is true
RES-002 Failure exposes error and isSuccess is false
RES-003 when calls success on Success
RES-004 when calls failure on Failure
RES-005 fold calls onSuccess on Success
RES-006 fold calls onFailure on Failure
```

`test/shared/error/app_error_test.dart`

```text
ERR-001 NetworkError is network-related and transient
ERR-002 TimeoutError is transient and not network-related
ERR-003 ApiError is not network-related and not transient
ERR-004 ApiError exposes statusCode
ERR-005 UnexpectedError is not network-related and not transient
ERR-006 toString includes runtimeType and technicalMessage
```

`test/shared/error/result_guard_test.dart`

```text
GD-001 returns Success on normal execution
GD-002 NetworkException without status maps to NetworkError
GD-003 NetworkException with 401 maps to ApiError(401)
GD-004 NetworkException with 500 maps to ApiError(500)
GD-005 TimeoutException maps to TimeoutError
GD-006 generic Exception maps to UnexpectedError
GD-007 rethrows Error instead of wrapping
```

### 11.2 Logger tests

`test/core/services/logging/dev_logger_test.dart`

```text
LOG-001 DevLogger.info does not throw
LOG-002 DevLogger.error does not throw with technicalMessage and stackTrace
LOG-003 loggerProvider resolves an instance compatible with ILogger
```

LOG-003 verifies that the provider resolves a value compatible with `ILogger`. The test does not inspect Riverpod internals.

### 11.3 Updated feature tests

`test/features/auth/infrastructure/repositories/auth_repository_impl_test.dart`

```text
AUTH-REPO-001 success returns Success(AuthSession)
AUTH-REPO-002 401 returns Failure(ApiError with statusCode 401)
AUTH-REPO-003 5xx returns Failure(ApiError with statusCode 5xx)
AUTH-REPO-004 transport failure without status returns Failure(NetworkError)
```

`test/features/auth/presentation/notifiers/auth_notifier_test.dart`

```text
AUTH-NOT-001 starts in AuthInitial
AUTH-NOT-002 success emits loading then AuthAuthenticated
AUTH-NOT-003 401 emits loading then AuthFailure with ApiError(401)
AUTH-NOT-004 network failure emits AuthFailure with NetworkError
AUTH-NOT-005 failure calls ILogger.error exactly once
AUTH-NOT-006 logger payload contains no sensitive data
AUTH-NOT-007 logout returns to AuthUnauthenticated
```

`test/features/accounts/...` mirrors AUTH-REPO/AUTH-NOT with accounts semantics and the `[accounts] load failed` message.

Updated additionally:

- `test/features/auth/integration/authentication_flow_test.dart`
- `integration_test/auth/authentication_flow_test.dart`
- `test/features/accounts/presentation/screens/accounts_screen_test.dart`
- Accounts integration and E2E tests.

Logger assertions use a `FakeLogger implements ILogger` injected by overriding `loggerProvider`. A helper asserts that no captured string contains `password`, `token`, or a full account number.

---

## 12. Acceptance Criteria

```text
AC-01 Features depend on Result<T> and never on DioException or NetworkException.
AC-02 No Feature defines its own error hierarchy after PR12.
AC-03 guard() is the only place that converts infrastructure exceptions to AppError.
AC-04 shared/ does not import core/ or features/.
AC-05 A failing Notifier emits a Failure state and calls ILogger.error once.
AC-06 No log message, technicalMessage, or stack-trace-associated payload
      contains sensitive data.
AC-07 Fresh features added later obtain error handling by using Result<T> and ILogger only.
AC-08 flutter analyze returns 0 issues and flutter test passes.
AC-09 No new dependency is introduced.
```

---

## 13. Affected Files

New:

```text
lib/shared/error/app_error.dart
lib/shared/error/result.dart
lib/shared/error/result_guard.dart
lib/shared/exceptions/network_exception.dart
lib/shared/interfaces/i_logger.dart
lib/core/services/logging/dev_logger.dart
lib/core/services/logging/logging_providers.dart
test/shared/error/result_test.dart
test/shared/error/app_error_test.dart
test/shared/error/result_guard_test.dart
test/core/services/logging/dev_logger_test.dart
docs/architecture/pr12-error-handling-and-development-logging.md
```

Modified:

```text
lib/core/network/network_exception.dart        (removed after relocation)
lib/core/network/dio_http_client.dart          (import update)
lib/features/auth/infrastructure/datasources/auth_remote_data_source.dart
lib/features/auth/infrastructure/repositories/auth_repository_impl.dart
lib/features/auth/domain/repositories/auth_repository.dart
lib/features/auth/presentation/auth_state.dart
lib/features/auth/presentation/notifiers/auth_notifier.dart
lib/features/auth/presentation/screens/login_screen.dart
lib/features/auth/di/auth_providers.dart       (unchanged unless needed)
lib/features/accounts/infrastructure/datasources/accounts_remote_data_source.dart
lib/features/accounts/infrastructure/repositories/accounts_repository_impl.dart
lib/features/accounts/domain/repositories/accounts_repository.dart
lib/features/accounts/presentation/accounts_state.dart
lib/features/accounts/presentation/notifiers/accounts_notifier.dart
lib/features/auth/spec/domain.md
lib/features/auth/spec/tests.md
lib/features/auth/spec/tasks.md
lib/features/accounts/spec/domain.md
lib/features/accounts/spec/tests.md
lib/features/accounts/spec/tasks.md
docs/product/requirements-traceability.md
(test files listed in section 11)
```

Removed:

```text
lib/features/auth/domain/errors/auth_error.dart
lib/features/accounts/domain/errors/accounts_error.dart
```

---

## 14. Traceability

| Item | Relationship |
|---|---|
| ADR-003 | Implements the documented "transport failure → application error → presentation state" boundary |
| ADR-009 | `ILogger` is the development seam; production observability is provided by `IObservability` bound through `observabilityProvider` (PR14) |
| REQ-009 | Explicit Failure states are the foundation for loading/retry/recovery |
| REQ-013 | Development logging is the first, non-production step of the monitoring strategy |
| REQ-022 | Engineering quality: explicit error model, testable providers, observability seam |
| SEC-005 | Sensitive-data logging is explicitly prohibited and tested |

---

## 15. Definition of Done

```text
1. Spec approved and frozen.
2. RED tests written for shared/error and logger.
3. GREEN for shared/error, ILogger, DevLogger, loggerProvider.
4. RED → GREEN for Auth migration.
5. RED → GREEN for Accounts migration.
6. dart format .
7. flutter analyze (0 issues).
8. flutter test (0 failures).
9. Feature specs and requirements-traceability updated.
10. Diff reviewed. Commit and PR only on explicit instruction.
```

---

## 16. Work Order

```text
1.  Freeze and store this specification.
2.  Define the exact test scenarios (section 11).
3.  Freeze contracts (sections 4 and 5).
4.  Review the specification.
5.  Write RED tests for shared/error.
6.  Implement shared/error to GREEN.
7.  Write RED tests for the logger; implement ILogger, DevLogger, loggerProvider to GREEN.
8.  Migrate Auth (RED → GREEN).
9.  Migrate Accounts (RED → GREEN).
10. Run full validation.
11. Update feature specs and requirements traceability.
12. Review diff. Prepare commit and PR only when instructed.
```
