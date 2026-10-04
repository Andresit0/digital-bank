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
rules. `AuthRepositoryImpl` puts the data-source result behind `guard()` and
returns the domain contract `Result<AuthSession>`.

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
HTTP 200              -> Success(AuthSession)
HTTP 401              -> Failure(ApiError 401)
HTTP 5xx              -> Failure(ApiError 5xx)
timeout / connection  -> Failure(NetworkError)
other Exception       -> Failure(UnexpectedError)
```

The mapping is performed by `guard()` (from `shared/error`) at the repository
boundary, not by `AuthRemoteDataSource`. `guard()` converts `NetworkException`
and other exceptions from the network boundary into the corresponding `AppError`
carried by `Result.failure`. `DioException` never crosses into the domain or
presentation.

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
