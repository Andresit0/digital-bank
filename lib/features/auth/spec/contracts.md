# Contracts: Authentication

## Internal Boundary

```text
LoginScreen
    |
    v
AuthNotifier
    |
    v
AuthRepository
    |
    v
AuthRemoteDataSource
    |
    v
HttpClient
    |
    v
configured backend
```

Dependency direction:

```text
presentation   -> domain
infrastructure -> domain
infrastructure -> core/network
```

The feature never depends on Dio directly.

## Assumed HTTP Contract

```text
POST /auth/login

Request:
{
  "email": String,
  "password": String
}

Response 200:
{
  "accessToken": String
}

Response 401:
invalid credentials

Response 5xx:
server failure

timeout / connection failure:
transport failure
```

This HTTP contract is an implementation assumption. It is isolated behind the
data-source and repository boundary so it can be replaced when a real backend
contract is provided.

## Endpoint Ownership

`/auth/login` is knowledge specific to the authentication infrastructure. It is a
private constant of `AuthRemoteDataSource`, not part of global configuration.

## Layer Responsibilities

```text
AuthRemoteDataSource  ->  HTTP request/response <-> AuthResponseModel
AuthRepositoryImpl    ->  infrastructure outcomes <-> domain outcomes
```

`AuthRemoteDataSource` executes the HTTP request and transforms a successful
response into `AuthResponseModel`. It does not know authentication business
rules. `AuthRepositoryImpl` translates infrastructure outcomes (`HttpResponse`,
`NetworkException`) into the domain contract (`AuthSession`, `AuthError`).

## AuthRemoteDataSource

```dart
abstract interface class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });
}
```

## AuthResponseModel

- accessToken: String
- Defined in infrastructure.
- Created from JSON via a `fromJson` factory.
- Mapped to `AuthSession` by the repository implementation.

## Error Mapping

```text
HTTP 200              -> AuthSession
HTTP 401              -> InvalidCredentials
HTTP 5xx              -> Network
timeout / connection  -> Network
```

The mapping is performed by `AuthRepositoryImpl`, not by `AuthRemoteDataSource`.
`NetworkException` from the network boundary is converted to the corresponding
`AuthError` in the repository implementation. `DioException` never crosses into
the domain or presentation.

## Configuration

```text
--dart-define=API_BASE_URL=...
          |
          v
       AppConfig
          |
          v
    appConfigProvider
          |
          v
      dioProvider
          |
          v
       HttpClient
          |
          v
  AuthRemoteDataSource
```

`AppConfig` exposes only `apiBaseUrl`. No production URL is invented. A default
may remain unconfigured and be provided at build time.

## State Exposure

`AuthNotifier` exposes an `AuthState`. Routing observes authentication state
through a `refreshListenable` adapter that triggers `GoRouter.refresh()`; the
router instance is not rebuilt when authentication state changes.
