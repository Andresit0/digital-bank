# Contracts: Movements

## Internal Boundary

```text
MovementsScreen
    |
    v
MovementsNotifier
    |
    v
MovementsRepository
    |
    v
MovementsRemoteDataSource
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
GET /accounts/{accountId}/movements

Response 200 with movements:
[
  {
    "id": String,
    "accountId": String,
    "type": String,
    "amount": double,
    "currency": String,
    "description": String,
    "occurredAt": String
  }
]

Response 200 with empty list:
[]

Response 401:
invalid credentials

Response 403:
account not authorized

Response 5xx:
server failure

timeout / connection failure:
transport failure
```

This is a single endpoint for listing movements. There is no dedicated detail
endpoint in this feature. The contract is an implementation assumption, isolated
behind the data-source and repository boundary so it can be replaced when a real
backend contract is provided.

## Endpoint Ownership

`/accounts/{accountId}/movements` is knowledge specific to the movements
infrastructure. It is a private constant of `MovementsRemoteDataSource`. The
`accountId` is a parameter of the request, not global configuration.

## Authorization Assumption

The authenticated backend session is responsible for authorizing access to the
account identified by `accountId`. The client does not treat the `accountId`
query parameter as proof of ownership. A movement response is considered valid
only within the authenticated customer's authorized account context. A backend
may respond `403` when the account is authenticated but not authorized.

## Layer Responsibilities

```text
MovementsRemoteDataSource  ->  HTTP request/response <-> MovementModel
MovementsRepositoryImpl    ->  infrastructure outcomes <-> domain outcomes
```

`MovementsRemoteDataSource` fetches the HTTP response and maps each item into
`MovementModel`. It does not know movements business rules.
`MovementsRepositoryImpl` puts the data-source result behind `guard()` and maps
the models into the domain contract `Result<List<Movement>>`.

## MovementsRemoteDataSource

```dart
abstract interface class MovementsRemoteDataSource {
  Future<List<MovementModel>> fetchMovements({required String accountId});
}
```

## MovementModel

- id: String
- accountId: String
- type: String
- amount: double
- currency: String
- description: String
- occurredAt: String
- Defined in infrastructure.
- Created from JSON via a `fromJson` factory.
- Mapped to `Movement` by the repository implementation.

## Error Mapping

```text
HTTP 200 with movements   -> Success(List<Movement>)
HTTP 200 with empty list  -> Success([])
HTTP 401                  -> Failure(ApiError 401)
HTTP 403                  -> Failure(ApiError 403)
HTTP 5xx                  -> Failure(ApiError 5xx)
invalid payload           -> Failure(ApiError 200)
timeout / connection      -> Failure(NetworkError)
```

The mapping is performed by `guard()` (from `shared/error`) at the repository
boundary, not by `MovementsRemoteDataSource`. `DioException` never crosses into
the domain or presentation.

## Navigation Boundary

```text
Home
    |
    v
context.push('/accounts?intent=movements')  (View Movements quick action)
    |
    v
AccountsScreen [selectForMovements: true]
    "Select an account"
    "Choose the account whose movements you want to view."
    |
    v
AccountCard (Accounts)
    |
    v
context.push(Uri(path: '/movements', queryParameters: {'accountId': id}).toString())
    |
    v
/movements?accountId=<accountId>
    |
    v
MovementsScreen reads accountId from GoRouterState.uri.queryParameters
    |
    v
MovementsNotifier.load(accountId)
    |
    v
fetchMovements(accountId: accountId)
    |
    v
context.push('/movements/:id')
    |
    v
/movements/:id renders MovementDetailScreen from the loaded Movement
```

`accountId` is mandatory and originates exclusively from the navigation context
(query parameters). The feature never infers a "selected account". `go_router`
is confined to the presentation boundary; the domain receives `accountId` only
as a rule parameter.

Navigation uses `push` so each transition adds a page to the navigation stack.
This keeps a coherent back history (`Back` and the iOS edge-swipe) from
Movements to Accounts and from Movement back to Movements.

The View Movements quick action opens Accounts as an explicit account-selection
step (`/accounts?intent=movements`), because the movements screen needs an
`accountId`. The router reads `intent` from `state.uri.queryParameters` and
passes `selectForMovements` to `AccountsScreen`, which presents the selection
copy instead of the normal accounts view. It does not open Movements directly.

The detail route `/movements/:id` resolves the `Movement` from the loaded list.
It does not call the network and there is no detail request. The detail route
requires the movement to be available from the previously loaded movements
context; it is not independently loadable or deep-linkable in this feature.

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
  MovementsRemoteDataSource
```

`AppConfig` exposes only `apiBaseUrl`. The movements endpoint path is owned by
the movements infrastructure.

## State Exposure

`MovementsNotifier` exposes a `MovementsState`. The screen observes it through
`ref.watch`. Access to movements depends on the authentication guard established
by the auth feature.

## Authentication

Protected endpoint.
Requires `Authorization: Bearer <accessToken>`.
The token is attached centrally by the shared API client; the feature never
reads or builds it. See `docs/architecture/pr18-api-integration.md`.
