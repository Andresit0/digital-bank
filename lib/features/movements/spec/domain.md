# Domain: Movements

## Entities

### Movement

- id: String
- accountId: String
- type: MovementType
- amount: double (positive)
- currency: String
- description: String
- occurredAt: DateTime

`Movement` is pure Dart. It does not depend on Flutter, Dio, `go_router`, or any
transport type. `amount` is a positive monetary value; the direction of the
operation is expressed by `type`.

## Enums

### MovementType

```text
MovementType
  credit
  debit
```

## Repository Contract

```dart
abstract interface class MovementsRepository {
  Future<Result<List<Movement>>> fetchMovements({
    required String accountId,
  });
}
```

`MovementsRepository` is the domain entry point for movements in this feature.
`accountId` is a plain domain parameter provided by the caller; the domain does
not know where it comes from. No use cases are introduced because the only
domain behavior is fetching the movement list.

There is no repository method for the detail. The detail view reuses a
`Movement` already loaded by `fetchMovements`.

## Presentation State

```text
sealed class MovementsState
  MovementsInitial
  MovementsLoading
  MovementsLoaded(List<Movement>)
  MovementsEmpty
  MovementsFailure(AppError)
```

`MovementsEmpty` is a valid state. A successful response with an empty list is
not an error. There is no independent detail state: the detail screen consumes a
`Movement` from `MovementsLoaded`.

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
HTTP 200 with movements   -> Success(List<Movement>)
HTTP 200 with empty list  -> Success([])
HTTP 401                  -> Failure(ApiError 401)
HTTP 403                  -> Failure(ApiError 403)
HTTP 5xx                  -> Failure(ApiError 5xx)
invalid payload           -> Failure(ApiError 200)
timeout / connection      -> Failure(NetworkError)
```

The domain never receives `DioException` or `NetworkException` directly as an
error type.

## Rules

- The domain does not import Flutter and does not import Dio.
- The domain does not import `go_router` and does not depend on navigation.
- The domain does not import `HttpResponse` or any transport contract.
- The domain depends on `shared/error` (`Result`, `AppError`).
- `accountId` enters the domain only as a parameter of `fetchMovements`.
- HTTP-to-domain mapping belongs to the infrastructure boundary via `guard()`.
- There are no use cases in this feature: the only domain behavior is
  `fetchMovements`.
- A movement `status` is not modeled in this feature.
