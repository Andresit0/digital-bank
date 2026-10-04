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
  Future<List<Account>> fetchAccounts();
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
  AccountsFailure(AccountsError)
```

`AccountsEmpty` is a valid state. A successful response with an empty list is
not an error.

## Domain Errors

```text
sealed class AccountsError
  AccountsInvalidCredentials
  AccountsNetwork
```

## Error Mapping

The mapping from transport and HTTP outcomes to `AccountsError` happens outside
the domain, in the infrastructure layer:

```text
HTTP 200 with accounts   -> List<Account>
HTTP 200 with empty list -> AccountsEmpty
HTTP 401                 -> AccountsInvalidCredentials
HTTP 5xx                 -> AccountsNetwork
timeout / connection     -> AccountsNetwork
```

The domain never receives `DioException` or `NetworkException` directly as an
error type. Infrastructure converts the transport outcome into the appropriate
`AccountsError` before it reaches the domain or presentation.

## Rules

- The domain does not import Flutter and does not import Dio.
- The domain does not import `HttpResponse` or any transport contract.
- HTTP-to-domain mapping belongs to infrastructure.
- There are no use cases in this feature: the only domain behavior is
  `fetchAccounts`.
- Movements are out of scope for this feature and are not modeled here.
