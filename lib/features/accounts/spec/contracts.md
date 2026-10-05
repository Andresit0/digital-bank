# Contracts: Accounts

## Internal Boundary

```text
AccountsScreen
    |
    v
AccountsNotifier
    |
    v
AccountsRepository
    |
    v
AccountsRemoteDataSource
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
GET /accounts

Response 200 with accounts:
[
  {
    "id": String,
    "type": String,
    "displayName": String,
    "maskedNumber": String,
    "availableBalance": double
  }
]

Response 200 with empty list:
[]

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

`/accounts` is knowledge specific to the accounts infrastructure. It is a
private constant of `AccountsRemoteDataSource`, not part of global
configuration.

## Layer Responsibilities

```text
AccountsRemoteDataSource  ->  HTTP request/response <-> AccountModel
AccountsRepositoryImpl    ->  infrastructure outcomes <-> domain outcomes
```

`AccountsRemoteDataSource` fetches the HTTP response and maps each item into
`AccountModel`. It does not know accounts business rules.
`AccountsRepositoryImpl` puts the data-source result behind `guard()` and maps
the models into the domain contract `Result<List<Account>>`.

## AccountsRemoteDataSource

```dart
abstract interface class AccountsRemoteDataSource {
  Future<List<AccountModel>> fetchAccounts();
}
```

## AccountModel

- id: String
- type: String
- displayName: String
- maskedNumber: String
- availableBalance: double
- Defined in infrastructure.
- Created from JSON via a `fromJson` factory.
- Mapped to `Account` by the repository implementation.

## Error Mapping

```text
HTTP 200 with accounts    -> Success(List<Account>)
HTTP 200 with empty list  -> Success([])
HTTP 401                  -> Failure(ApiError 401)
HTTP 5xx                  -> Failure(ApiError 5xx)
invalid payload           -> Failure(ApiError 200)
timeout / connection      -> Failure(NetworkError)
```

The mapping is performed by `guard()` (from `shared/error`) at the repository
boundary, not by `AccountsRemoteDataSource`. `guard()` converts `NetworkException`
from the network boundary into the corresponding `AppError` carried by
`Result.failure`. `DioException` never crosses into the domain or presentation.

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
  AccountsRemoteDataSource
```

`AppConfig` exposes only `apiBaseUrl`. The accounts endpoint path is owned by
the accounts infrastructure.

## State Exposure

`AccountsNotifier` exposes an `AccountsState`. The screen observes it through
`ref.watch`. Accounts does not participate in authentication routing; access to
the accounts area depends on the authentication guard established by the auth
feature.

## Authentication

Protected endpoint.
Requires `Authorization: Bearer <accessToken>`.
The token is attached centrally by the shared API client; the feature never
reads or builds it. See `docs/architecture/pr18-api-integration.md`.
