# Domain: Authentication

## Entities

### AuthSession

- accessToken: String

`AuthSession` is pure Dart. It does not depend on Flutter, Dio, or any
transport type. It represents a successful authentication result in memory.

## Repository Contract

```dart
abstract interface class AuthRepository {
  Future<AuthSession> login({
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
  AuthFailure(AuthError)
```

## Domain Errors

```text
sealed class AuthError
  InvalidCredentials
  Network
```

## Error Mapping

The mapping from transport and HTTP outcomes to `AuthError` happens outside the
domain, in the infrastructure layer:

```text
HTTP 200                  -> AuthSession
HTTP 401                  -> InvalidCredentials
HTTP 5xx                  -> Network
timeout / connection      -> Network
```

The domain never receives `DioException` or `NetworkException` directly as an
error type. Infrastructure converts the transport outcome into the appropriate
`AuthError` before it reaches the domain or presentation.

## Rules

- The domain does not import Flutter and does not import Dio.
- The domain does not import `HttpResponse` or any transport contract.
- HTTP-to-domain mapping belongs to infrastructure.
- There are no use cases in this feature: the only domain behavior is `login`.
