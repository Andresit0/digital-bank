# Feature: Authentication

## Purpose

Allow a customer to authenticate with email and password to enter the
authenticated area of the application, using the architecture already
established by the application composition root, router, dependency
composition, and network abstraction.

## Scope

- Email and password login.
- Local form validation.
- Login request through the application-owned `HttpClient`.
- In-memory authenticated session.
- Explicit authentication states.
- Authentication failure handling.
- Local logout.
- Minimal authentication routing and guard.

## Out of Scope

- Refresh tokens.
- OAuth.
- Biometrics.
- Multi-factor authentication.
- Password recovery.
- Registration.
- Account lockout.
- Secure storage.
- Session persistence across application restarts.
- Offline authentication.
- Certificate pinning.
- Advanced retry.
- Remote logout.
- Complex authorization middleware.
- Use cases without demonstrated need.
- A BDD execution runner.

## Actors

- Unauthenticated user.
- Authenticated user.

## Functional Requirements

- AUTH-001 The customer authenticates using email and password.
- AUTH-002 The credentials are sent through the application-owned `HttpClient`.
- AUTH-003 A successful authentication produces an `AuthSession`.
- AUTH-004 Invalid credentials produce an authentication error without creating a session.
- AUTH-005 A network failure produces a recoverable error without exposing Dio.
- AUTH-006 The UI represents initial, loading, authenticated, and error states.
- AUTH-007 The authenticated user can access `/home`; the unauthenticated user is redirected to login.
- AUTH-008 The authenticated user can log out, clearing the session.

## Authentication State

```text
initial
   |
   v
unauthenticated
   |
   v
loading
   |
   +--> authenticated
   |
   +--> error
```

```text
authenticated
   |
   v
logout
   |
   v
unauthenticated
```

`unauthenticated` is an internal state of the feature. It is required by the
logout flow and by the routing guard, but it does not necessarily have a screen
of its own.

## Business Rules

- Email is required and must have a valid format.
- Password is required.
- Duplicate login requests are prevented while loading.
- The session lives in memory only and does not survive an application restart.

## Security

- Credentials are transmitted through the configured HTTPS transport.
- Client-side password hashing is out of scope because the assessment does not
  define such a protocol.
- The session is memory-only. Secure credential storage is deferred: `SEC-004`
  is not implemented in this feature because no secure storage exists yet.

## Contract Assumption

The assessment does not define an authentication API contract. This feature
establishes an implementation-level authentication contract as an explicit
assumption, isolated behind the repository and data-source boundary so it can be
replaced when an actual backend contract is provided.

The assumed endpoint `POST /auth/login` is an implementation assumption, not an
assessment requirement.

## Dependencies

- `HttpClient` and `network_providers` from the network foundation.
- Riverpod for state management and dependency composition.
- go_router for routing.
- No new dependencies.

## Traceability

- REQ-001 Customer onboarding and authentication.
- REQ-009 Loading, retry, cache, and recovery states.
- REQ-023 Usable and coherent experience.
- REQ-010 Unit tests.
- REQ-011 Widget tests.
- SEC-001 Credentials and token handling, in memory only.
- SEC-004 Secure credential storage, deferred.

## Acceptance Criteria

- AUTH-001 Valid credentials produce an authenticated session.
- AUTH-002 The login request is delegated to the application-owned `HttpClient`.
- AUTH-003 A successful response produces an `AuthSession`.
- AUTH-004 Invalid credentials produce an authentication error and no session.
- AUTH-005 A network failure produces a recoverable error without exposing Dio.
- AUTH-006 The application represents initial, loading, authenticated, and error states.
- AUTH-007 The authenticated area is protected and redirects unauthenticated users to login.
- AUTH-008 Logout clears the session and returns the user to login.
