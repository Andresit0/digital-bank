# PR18 — Flutter to NestJS API Integration

## Document Information

| Field | Value |
|---|---|
| Project | Digital Financial Platform — Flutter Technical Assessment |
| Document | PR18 Specification — Flutter to NestJS API Integration |
| Status | Frozen (approved) |
| Related ADR | ADR-003 (Networking, Error Handling and Resilience Boundaries) |
| Related Requirements | REQ-001, REQ-002, REQ-003, SEC-001, CON-002 |
| Depends on | PR17 (NestJS backend foundation) |
| Scope | Cross-cutting (`core/session`, `core/network`) plus Auth wiring |

---

## 1. Purpose

Secure and complete the existing Flutter-to-API integration by introducing
centralized in-memory session management, Bearer authentication, explicit 401
handling, and validated integration against the NestJS backend.

PR18 is an evolution of the networking boundary established by ADR-003, not a
reconstruction. The existing `HttpClient`, `DioHttpClient`, `Dio` provider,
`Result`, `AppError`, and `guard()` remain in place. The data sources already
target the real API paths. What is missing is a single, centralized mechanism
that attaches the access token to protected requests and reacts to an
authentication failure.

---

## 2. Current State and Gap

The Feature → Repository → Data Source → `HttpClient` → backend flow already
exists. All four data sources call the shared `HttpClient` and target the real
paths (`/auth/login`, `/accounts`, `/accounts/:accountId/movements`,
`/experience/home`).

The gap is authentication transport: the `accessToken` returned by login is kept
in the authentication state but is never attached to outgoing requests. A search
across `lib/` for `Bearer`, `Authorization`, `interceptor`, or `SessionManager`
returns no matches.

As a result, protected endpoints currently appear to succeed only because the
deterministic test server does not validate the `Authorization` header. After
PR18, the test server rejects protected requests without a valid Bearer token,
so the integration scenarios actually exercise authentication.

### Endpoint and Authorization Matrix

| Endpoint | Method | Backend requires Bearer | App sends it today | App sends it after PR18 |
|---|---|---|---|---|
| `/auth/login` | POST | No (public) | — | Public |
| `/accounts` | GET | Yes | No | Yes (interceptor) |
| `/accounts/:accountId/movements` | GET | Yes | No | Yes (interceptor) |
| `/experience/home` | GET | Yes | No | Yes (interceptor) |
| `/auth/me` | GET | Yes | Not consumed | Out of scope for PR18 |

---

## 3. Frozen Decisions

| ID | Decision |
|---|---|
| D1 | `SessionManager` is in-memory only: `accessToken`, `setToken()`, `clear()`, `hasSession`. No Secure Storage, no refresh tokens, no persistence, no biometric authentication. |
| D2 | The token stays out of features. No feature receives the token as a parameter and no feature builds an `Authorization` header. |
| D3 | The Bearer token is injected centrally by a `Dio` interceptor under `core/network`. |
| D4 | On `401`, the interceptor calls `SessionManager.clear()`. Networking never navigates. Authentication state changes, and the router reacts by sending the user to login. |
| D5 | Two E2E levels: a deterministic server (`ApiHttpServer`) that validates Bearer, and an optional real NestJS E2E that is skipped unless a backend is reachable. Real E2E runs by default when the backend is available, and can be forced with `RUN_REAL_API_E2E=1`. The auto-probe only decides whether the real test may run; it never hides a failure once the test has started. |
| D6 | `HttpClient` keeps its current API. Its signature does not change. |
| D7 | No new ADR is created. PR18 extends the networking boundary defined by ADR-003. |

Dependency direction remains:

```text
shared  <-  core  <-  features
```

Features depend on the application-level `HttpClient`; they never depend on
`Dio` or on the session mechanism directly.

---

## 4. Contracts

### 4.1 `lib/core/session/session_manager.dart`

```dart
class SessionManager {
  String? get accessToken;
  bool get hasSession;
  void setToken(String token);
  void clear();
}
```

The implementation is in-memory. No persistence is introduced.

### 4.2 `lib/core/session/session_providers.dart`

```dart
final sessionManagerProvider = Provider<SessionManager>((ref) => SessionManager());
```

### 4.3 Bearer interceptor (conceptual, `core/network`)

The `dioProvider` attaches an interceptor that:

1. reads the current token from `SessionManager`;
2. adds `Authorization: Bearer <token>` when a session exists;
3. on a `401` response, calls `SessionManager.clear()` and does not navigate.

The interceptor does not depend on the router or on any presentation code.

---

## 5. Flow Diagrams

Authenticated request flow:

```text
AuthNotifier
     │
     │ login
     ▼
SessionManager
     │
     │ accessToken
     ▼
Dio Interceptor
     │
     │ Authorization: Bearer <token>
     ▼
NestJS API
     │
     ▼
PostgreSQL
```

Authentication failure flow:

```text
NestJS API
    │
    │ 401
    ▼
Dio Interceptor
    │
    ▼
SessionManager.clear()
    │
    ▼
Auth state
    │
    ▼
Router
    │
    ▼
Login
```

---

## 6. Scenarios

```text
INT/API-001  Login with valid credentials stores the session token
INT/API-002  Invalid login does not store a token and surfaces AuthFailure
INT/API-003  GET /accounts sends Authorization: Bearer and renders accounts
INT/API-004  A protected request without a session returns 401,
             clears the session, and returns the user to login
INT/API-005  GET /accounts/:accountId/movements sends Authorization: Bearer
INT/API-006  GET /experience/home sends Authorization: Bearer and renders
             the dynamic experience

E2E/API-001       Login -> Accounts -> Movements -> Experience against the
                  deterministic test server
E2E/API-REAL-001  The same journey against a locally running NestJS backend
                  (skipped unless reachable; forced with RUN_REAL_API_E2E=1)
```

---

## 7. Acceptance Criteria

```text
AC-01 SessionManager is in-memory and exposed through sessionManagerProvider.
AC-02 No feature reads, stores, or builds the access token.
AC-03 Protected requests carry Authorization: Bearer centrally.
AC-04 A 401 clears the session; networking does not navigate.
AC-05 The router returns the user to login after the session is cleared.
AC-06 ApiHttpServer rejects protected requests without a valid Bearer token.
AC-07 Errors continue to flow through Result / AppError / guard().
AC-08 flutter analyze returns 0 issues and flutter test passes.
AC-09 The existing test suite remains green.
```

---

## 8. Traceability (Target)

This section states the objective of PR18. The traceability matrix is updated
with evidence only after implementation and validation (Commit 9).

```text
CON-002  Real service interaction or dynamic processing
         -> PR18 provides evidence of the Flutter app consuming the real
            NestJS API through authenticated requests.

SEC-001  Credentials and token handling
         -> The access token is stored in memory and attached centrally;
            it is never logged, persisted, or exposed to features.

REQ-001  Auth / REQ-002 Accounts and Movements / REQ-003 Dynamic Experience
         -> Consumed through authenticated requests against the real backend.
```

---

## 9. Out of Scope

- `GET /auth/me` (session restore/validation at startup).
- Secure Storage, refresh tokens, token rotation, biometric authentication.
- Multi-account sessions, offline synchronization.
- Crashlytics or any external service (PR19).
- Push notifications (PR20).
- Personalization engine, feature flags, A/B testing.
- Backend production deployment.

---

## 10. Definition of Done

```text
Architecture
- SessionManager in-memory and sessionManagerProvider.
- Dio interceptor reads the token from SessionManager.
- No feature receives the token as a parameter.
- No feature builds an Authorization header.
- HttpClient keeps its current API.

Authentication
- Login obtains a real JWT.
- The JWT is stored in SessionManager.
- Logout clears SessionManager.
- An invalid login leaves no stored token.

Protected API
- Accounts, Movements, and Experience send Bearer.
- ApiHttpServer validates Bearer.
- A protected request without a token returns 401.

401
- A 401 clears the session.
- Networking does not navigate directly.
- Authentication state drives navigation to Login.

Tests
- SessionManager unit tests.
- Interceptor tests.
- INT/API-001..006.
- E2E/API-001.
- Optional/skippable real NestJS E2E.
- The existing suite remains green.

Validation
- flutter analyze clean.
- flutter test green.
- git diff --check clean.
- Real backend verified locally.
- README updated.
- Traceability updated.
```

---

## 11. Commit Plan

```text
1 docs(api-integration): add PR18 specification
2 feat(session): add in-memory session manager
3 feat(api-client): attach bearer token and handle 401
4 feat(auth-api): store session on login and clear on logout
5 feat(accounts-api): assert bearer on accounts requests
6 feat(movements-api): assert bearer on movements requests
7 feat(experience-api): assert bearer on experience requests
8 test(api-integration): add auth scenarios and real-backend E2E
9 docs(api-integration): update README and traceability
```

Commits represent logical units of change, not a one-to-one mapping with each
feature. If commits 5 to 7 do not represent independent real changes, they are
merged rather than kept artificially.
