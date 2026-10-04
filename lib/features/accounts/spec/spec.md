# Feature: Accounts

## Purpose

Allow an authenticated customer to view their accounts, their type, their
masked number, and their available balance after entering the authenticated
area of the application.

## Scope

- List the accounts of the authenticated customer.
- Show the account type: savings or checking.
- Show a display name and a masked account number.
- Show the available balance.
- Explicit loading, loaded, empty, and error states.

## Out of Scope

- Account movements and transaction history.
- Transaction detail.
- Transfers between accounts.
- Account creation or modification.
- Personalized or dynamically generated account presentation.
- Real backend integration.
- Token persistence, refresh, or session restoration.

Movements are explicitly deferred to a later pull request. This feature
partially implements REQ-002: accounts and balances only.

## Actors

- Authenticated customer.

## Functional Requirements

- ACC-001 The authenticated customer can view their accounts.
- ACC-002 The customer can view the account type (savings or checking).
- ACC-003 The customer can view the masked account number.
- ACC-004 The customer can view the available balance of each account.
- ACC-005 The application represents loading, loaded, empty, and error states.
- ACC-006 An empty account list is a valid state, not an error.
- ACC-007 The customer is not shown accounts of other customers.

## Account State

```text
initial
   |
   v
loading
   |
   +--> loaded(List<Account>)
   |
   +--> empty
   |
   +--> failure(AppError)
```

## Business Rules

- Only the accounts of the authenticated customer are represented.
- Account numbers are shown masked, never in full.
- The available balance is a numeric value in the domain; formatting is a
  presentation concern.
- An empty response is a successful outcome with no accounts to display.

## Contract Assumption

The assessment does not define an accounts API contract. This feature
establishes an implementation-level contract as an explicit assumption,
isolated behind the repository and data-source boundary so it can be replaced
when an actual backend contract is provided.

The assumed endpoint `GET /accounts` is an implementation assumption, not an
assessment requirement.

## Dependencies

- `HttpClient` and `network_providers` from the network foundation.
- Authentication session from the auth feature (the customer is authenticated).
- Riverpod for state management and dependency composition.
- go_router for routing.
- No new dependencies.

## Traceability

- REQ-002 Account management, balances, and movements (partial: accounts and
  balances only; movements deferred).
- REQ-009 Loading, retry, cache, and recovery states.
- REQ-023 Usable and coherent experience.
- REQ-010 Unit tests.
- REQ-011 Widget tests.
- REQ-012 Critical end-to-end flow.

## Acceptance Criteria

- ACC-001 Authenticated customers see their accounts.
- ACC-002 Savings and checking accounts are distinguishable.
- ACC-003 Account numbers are displayed masked.
- ACC-004 Available balances are displayed.
- ACC-005 Loading, loaded, empty, and error states are represented.
- ACC-006 An empty response produces the empty state, not an error.
- ACC-007 Only the authenticated customer's accounts are shown.
