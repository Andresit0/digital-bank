# Feature: Movements

## Purpose

Allow an authenticated customer to view the movement history of a selected
account and inspect the detail of a movement, using the architecture already
established: feature-first Clean Architecture, the shared error model
(`Result<T>` / `AppError` / `guard()`), and the provider-agnostic observability
seam (`IObservability`).

## Scope

- List the movements of one account identified by `accountId`.
- Show the movement type (credit or debit).
- Show the amount and currency.
- Show the description and the date (`occurredAt`).
- Explicit initial, loading, loaded, empty, and failure states.
- Open a movement detail from the loaded list, without an additional HTTP request.
- Navigate from Accounts to Movements and from Movements to Detail.

## Out of Scope

- Transfers and movement creation or modification.
- Search, filters, and pagination.
- Cache and offline behavior.
- Attachments, categorization, and notes.
- A transactional `status` field.
- A dedicated detail endpoint.
- Push notifications and external service integration.

## Actors

- Authenticated customer.

## Functional Requirements

- MOV-001 The customer views the movements of a selected account identified by
  `accountId`.
- MOV-002 The customer can view the movement type (credit or debit).
- MOV-003 The customer can view the amount and currency.
- MOV-004 The customer can view the description and `occurredAt`.
- MOV-005 The application represents initial, loading, loaded, empty, and failure
  states.
- MOV-006 The customer can open a movement detail from the loaded list, without
  an additional HTTP request.
- MOV-007 The customer is only shown movements of their authorized account.
  Account ownership and authorization are enforced by the authenticated backend
  session, not by the client.

## Movement State

```text
initial
   |
   v
loading
   |
   +--> loaded(List<Movement>)
   |
   +--> empty
   |
   +--> failure(AppError)
```

## Navigation

```text
Home
  |
  v
Accounts
  |
  v
AccountCard (tap)
  |
  v
/movements?accountId=<accountId>
  |
  v
Movements (list)
  |
  v
MovementTile (tap)
  |
  v
/movements/:id
  |
  v
Movement Detail
```

`accountId` is part of the navigation context. It is read from
`GoRouterState.uri.queryParameters` and passed explicitly to the repository
contract. `accountId` is mandatory to load the list; the feature never infers a
"selected account". The domain does not know `go_router`.

The detail screen reuses the `Movement` already loaded in the list. It does not
perform an implicit HTTP request and there is no dedicated detail endpoint. The
movement detail route requires the movement to be available from the previously
loaded movements context. It is not independently loadable and does not support
fetching the movement by id.

## Business Rules

- `Movement.type` is `credit` or `debit`.
- `Movement.amount` is a positive monetary value; the direction belongs to
  `type`.
- `Movement.currency` is required.
- `Movement.occurredAt` represents when the movement occurred.
- An empty response is a successful outcome with no movements to display.
- `accountId` is required and comes from the navigation context.
- The client does not treat `accountId` as proof of ownership; the authenticated
  backend session authorizes access to the account.
- Formatting (signs, currency, dates) is a presentation concern.

## Contract Assumption

The assessment does not define a movements API contract. This feature
establishes an implementation-level contract as an explicit assumption, isolated
behind the data-source and repository boundary:

```text
GET /accounts/{accountId}/movements
```

The contract is a single endpoint for listing movements. The detail view does
not add a second endpoint. The assumed contract can be replaced when a real
backend contract is provided, without changes to domain or presentation.

Authorization assumption: the authenticated backend session is responsible for
authorizing access to the account identified by `accountId`. The client does not
treat `accountId` as proof of ownership. A movement response is considered valid
only within the authenticated customer's authorized account context. A backend
may respond `403` when the account is authenticated but not authorized.

## Dependencies

- `HttpClient` and `network_providers` from the network foundation.
- Authentication session from the auth feature (the customer is authenticated).
- `shared/error` (`Result`, `AppError`, `guard()`).
- `IObservability` and `observabilityProvider` from the observability foundation.
- Riverpod for state management and dependency composition.
- go_router for routing (presentation boundary only).
- No new dependencies.

## Traceability

- REQ-002 Account management, balances, and movements (movements part).
- REQ-009 Loading, retry, cache, and recovery states.
- REQ-023 Usable and coherent experience.
- REQ-010 Unit tests.
- REQ-011 Widget tests.
- REQ-012 Critical end-to-end flow.
- ADR-003 Networking and error boundaries.
- ADR-009 Observability and monitoring.

## Acceptance Criteria

- MOV-001 Authenticated customers see the movements of the account selected in
  the navigation context.
- MOV-002 Credit and debit movements are distinguishable.
- MOV-003 Amounts and currencies are displayed.
- MOV-004 Descriptions and dates are displayed.
- MOV-005 Loading, loaded, empty, and error states are represented.
- MOV-006 A movement detail opens from the loaded list without a new HTTP request.
- MOV-007 Only the authenticated customer's movements are shown; ownership is
  enforced by the authenticated backend session.
