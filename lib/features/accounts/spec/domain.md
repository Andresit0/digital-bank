# Domain: Accounts

## Entities

### Account

- id: String
- type: AccountType
- displayName: String
- maskedNumber: String
- availableBalance: double

`Account` is pure Dart. It does not depend on Flutter, Dio, or any transport
type. The available balance is a numeric value; formatting belongs to
presentation.

## Enums

### AccountType

```text
AccountType
  savings
  checking
```

## Repository Contract

```dart
abstract interface class AccountsRepository {
  Future<Result<List<Account>>> fetchAccounts();
}
```

`AccountsRepository` is the domain entry point for accounts in this feature.
No use cases are introduced because the only domain behavior is fetching the
account list.

## Presentation State

```text
sealed class AccountsState
  AccountsInitial
  AccountsLoading
  AccountsLoaded(List<Account>)
  AccountsEmpty
  AccountsFailure(AppError)
```

`AccountsEmpty` is a valid state. A successful response with an empty list is
not an error.

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
HTTP 200 with accounts   -> Success(List<Account>)
HTTP 200 with empty list -> Success([])
HTTP 401                 -> Failure(ApiError 401)
HTTP 5xx                 -> Failure(ApiError 5xx)
invalid payload          -> Failure(ApiError 200)
timeout / connection     -> Failure(NetworkError)
```

The domain never receives `DioException` or `NetworkException` directly as an
error type. `guard()` converts the transport outcome into the appropriate
`AppError` before it reaches the domain or presentation.

## Rules

- The domain does not import Flutter and does not import Dio.
- The domain does not import `HttpResponse` or any transport contract.
- The domain depends on `shared/error` (`Result`, `AppError`).
- HTTP-to-domain mapping belongs to the infrastructure boundary via `guard()`.
- There are no use cases in this feature: the only domain behavior is
  `fetchAccounts`.
- Movements are out of scope for this feature and are not modeled here.
