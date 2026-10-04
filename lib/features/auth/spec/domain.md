# Domain: Authentication

## Entities

### AuthSession

- accessToken: String

`AuthSession` is pure Dart. It does not depend on Flutter, Dio, or any
transport type. It represents a successful authentication result in memory.

## Repository Contract

```dart
abstract interface class AuthRepository {
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  });
}
```

`AuthRepository` is the domain entry point for authentication in this feature.
No use cases are introduced because the only domain behavior is `login`.

## Presentation State

```text
sealed class AuthState
  AuthInitial
  AuthUnauthenticated
  AuthLoading
  AuthAuthenticated(AuthSession)
  AuthFailure(AppError)
```

## Errors

The feature does not define its own error hierarchy. Failures are represented by
`AppError` from `shared/error`, carried inside `Result.failure`:

```text
sealed class AppError
  NetworkError
  TimeoutError
  ApiError
  UnexpectedError
```

## Error Mapping

The mapping from transport and HTTP outcomes to `AppError` happens at the
infrastructure boundary through `guard()` (from `shared/error`), not in the
domain:

```text
HTTP 200                  -> Success(AuthSession)
HTTP 401                  -> Failure(ApiError 401)
HTTP 5xx                  -> Failure(ApiError 5xx)
timeout / connection      -> Failure(NetworkError)
other Exception           -> Failure(UnexpectedError)
```

The domain never receives `DioException` or `NetworkException` directly as an
error type. `guard()` converts the transport outcome into the appropriate
`AppError` before it reaches the domain or presentation.

## Rules

- The domain does not import Flutter and does not import Dio.
- The domain does not import `HttpResponse` or any transport contract.
- The domain depends on `shared/error` (`Result`, `AppError`).
- HTTP-to-domain mapping belongs to the infrastructure boundary via `guard()`.
- There are no use cases in this feature: the only domain behavior is `login`.
