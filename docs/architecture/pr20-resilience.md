# PR20 — Resilience (Retry, Cache, Connectivity, Degraded States)

## Document Information

| Field | Value |
|---|---|
| Project | Digital Financial Platform — Flutter Technical Assessment |
| Document | PR20 Specification — Resilience |
| Status | Frozen (approved) |
| Related ADR | ADR-003 (Networking, Error Handling and Resilience Boundaries), ADR-004 (Resilience Policy) |
| Related Requirements | REQ-006 (limited connectivity), REQ-007 (high latency), REQ-008 (partial service unavailability), REQ-009 (loading, retry, cache and recovery states) |
| Depends on | PR12 (error handling), PR14 (observability), PR18 (API integration) |
| Scope | Cross-cutting (`core/network`, `shared`) and the Accounts, Movements, and Experience features |
| Platform | Flutter (all platforms) |

---

## 1. Purpose

Make the application resilient to limited connectivity, high latency, and
partial service unavailability without turning it into an offline-first client.

PR20 implements a bounded retry policy at the network boundary, a reusable
in-memory read cache whose fallback is owned by the read use case, a shared
`Read<T>` contract that carries staleness, a connectivity abstraction that
labels degraded reasons, and failure isolation so an optional service cannot
take down the core journey.

---

## 2. Frozen Decisions

| ID | Decision |
|---|---|
| D1 | Retry is bounded: at most 2 retries (3 attempts total). |
| D2 | Backoff is exponential: 300 ms then 600 ms, with no jitter. |
| D3 | Retryable errors are transient transport failures and selected `5xx` (`502`, `503`, `504`). |
| D4 | `4xx`, `401`, `403`, cancellation, and non-idempotent operations are never retried. |
| D5 | Retry applies only to reads / idempotent operations (`GET`). |
| D6 | Retry lives in `core/network` as a Dio interceptor with an injectable delay. |
| D7 | The cache is a reusable in-memory service under `core/network`; it is never persisted. |
| D8 | The cache applies only to `GET`/read requests. |
| D9 | The cache fallback is decided by the read use case, only after retry is exhausted. |
| D10 | A fresh remote response always wins; there is no TTL. |
| D11 | Staleness is carried by a shared `Read<T>` contract and surfaced explicitly. |
| D12 | The cache is cleared when the session is cleared (logout / `401`). |
| D13 | Connectivity is an application-defined abstraction; `connectivity_plus` is an infrastructure adapter and only a signal. |
| D14 | Connectivity is observational; recovery is a user-initiated retry (no auto-refetch). |
| D15 | A failure in an optional service degrades it; it does not fail the core journey (REQ-008). |
| D16 | `Read<T>` lives in `lib/shared/`; the domain does not depend on `core/network`. |
| D17 | PR scope is `resilience`; branch is `feat/resilience`. |
| D18 | The policy does not define offline-first sync or conflict resolution. |

Dependency direction remains:

```text
shared  <-  core  <-  features
```

---

## 3. Scope Boundaries

In scope: bounded retry, an in-memory read cache with a use-case-owned fallback,
a shared `Read<T>` contract, stale/degraded presentation states, a connectivity
abstraction, and failure isolation for Experience.

Out of scope: offline-first synchronization, persistent caching, conflict
resolution, delta sync, background synchronization, cache eviction/TTL, jitter,
and retry of non-idempotent operations.

---

## 4. Flow

### 4.1 Retry

```text
GET request
    |
    v
Dio
    |
    +-- success ---------------------------> response
    |
    +-- transient / 502|503|504 ----------> wait 300ms -> attempt 2
    |                                           |
    |                                           +-- success -> response
    |                                           |
    |                                           +-- transient -> wait 600ms -> attempt 3
    |                                                                |
    |                                                                +-- success -> response
    |                                                                |
    |                                                                +-- failure -> surface error
    |
    +-- 4xx / 401 / 403 / cancel ----------> surface error (no retry)
```

### 4.2 Cache and stale (owned by the read use case)

```text
Read use case (repository)
    |
    v
remote request (retry already exhausted on failure)
    |
    +-- success --> update read cache --> Read(source: remote)
    |
    +-- failure
          |
          +-- cache hit  --> Read(source: cache)  [stale] --> degraded state
          |
          +-- cache miss --> failure state
```

Retry always runs to exhaustion before the cache is consulted. The cache does
not know the retry policy.

### 4.3 Failure isolation (Experience)

```text
Experience remote failure
    |
    v
degraded Experience (static Home fallback)
    |
    v
Home remains usable  (REQ-008)
```

---

## 5. Contracts

### 5.1 Network layer (`lib/core/network/`)

- `retry_policy.dart`
  - `maxRetries = 2`
  - `baseDelay = 300 ms`
  - `retryableStatuses = {502, 503, 504}`
- `retry_interceptor.dart`
  - `RetryInterceptor implements Interceptor`
  - retries on `onError` only when: method is `GET`; the error is not
    `DioExceptionType.cancel`; the error is transient or is a retryable status;
    and `attempt < maxRetries`.
  - tracks the attempt in `options.extra['retry_attempt']`.
  - waits `baseDelay * 2^attempt` through an injected sleeper so tests do not
    actually wait.
  - on exhaustion, forwards the original error.
- `read_cache.dart`
  - `ReadCache` — generic in-memory store: `put(key, value)`, `get(key)`,
    `clear()`. It is a service consumed by read use cases; it makes no decision
    about when to serve stale data.
  - keys are chosen by the caller (e.g. `accounts`, `movements:<accountId>`).
- `connectivity_checker.dart`
  - `ConnectivityStatus` — `online` | `offline`.
  - `ConnectivityChecker` (application interface)
    - `Future<ConnectivityStatus> check();`
    - `Stream<ConnectivityStatus> get statusChanged;`
  - `ConnectivityPlusChecker implements ConnectivityChecker` — infrastructure
    adapter over `connectivity_plus`. It reports a link state only; it is not
    authoritative about reachability.
- Interceptor order in `network_providers.dart`: **Auth -> Retry**.
- Providers expose the retry policy, the `ReadCache`, and the connectivity
  checker.

### 5.2 Retry policy

| Policy | Decision |
|---|---|
| Retry | At most 2 retries |
| Total attempts | 3 |
| Backoff | Exponential |
| Delays | 300 ms -> 600 ms |
| Retryable | Transient errors |
| HTTP retryable | `502`, `503`, `504` |
| `4xx` | No retry |
| `401` / `403` | No retry |
| Cancellation | No retry |
| Operations | Reads / idempotent only |

### 5.3 Cache policy

| Policy | Decision |
|---|---|
| Storage | In-memory (`ReadCache` service) |
| Persistence | None |
| Operations | `GET` / read only |
| Fallback owner | The read use case (repository) |
| Timing | Only after retry is exhausted |
| Freshness | Fresh remote always wins |
| TTL | None |
| Invalidation | Cleared on session clear |

### 5.4 Shared read contract (`lib/shared/`)

```text
Read<T> { T data; ReadSource source; }   // ReadSource: remote | cache
Read<T>.isStale == (source == cache)
```

- The domain and features depend on `shared`, not on `core/network`.
- Accounts: `Result<Read<List<Account>>>`
- Movements: `Result<Read<List<Movement>>>`
- Experience: unchanged (`Result<ExperienceDefinition>`); Experience does not
  use the cache.

### 5.5 Presentation states

Accounts and Movements add an explicit stale state:

```text
AccountsStale(List<Account> accounts)
MovementsStale(List<Movement> movements)
```

Retry and recovery are user-initiated transitions from `failure`/`stale` back
through `loading`.

Experience keeps `ExperienceFailure`, treated explicitly as a degraded state
that renders the static Home fallback and offers a retry.

### 5.6 Observability

Non-sensitive events only (event name, `errorType`, `statusCode`, `attempt`):

```text
request_retried
accounts_stale_served
movements_stale_served
experience_degraded
```

Never logged: tokens, credentials, account numbers, `maskedNumber`, balances,
or payloads (SEC-005).

---

## 6. Failure Isolation

A failure in Experience must not fail Home. Experience degrades to its static
fallback and remains independently recoverable. This is the concrete response
to REQ-008 and reuses the existing static fallback rather than replacing it.

---

## 7. Scenarios

```text
RES-001  A transient transport failure on a GET is retried up to 2 times.
RES-002  Backoff is 300 ms then 600 ms.
RES-003  A 4xx response is not retried.
RES-004  401/403 are not retried.
RES-005  A cancelled request is not retried.
RES-006  A POST is not retried.
RES-007  502/503/504 are retried.
RES-008  Retry exhaustion surfaces the mapped error.
RES-009  A successful read updates the cache.
RES-010  A failed read with a cache hit returns Read(source: cache) marked stale.
RES-011  A failed read with no cache hit produces a failure state.
RES-012  A fresh remote response replaces cached data.
RES-013  Accounts exposes a stale state when serving cached data.
RES-014  Movements exposes a stale state when serving cached data.
RES-015  Retry from failure/stale transitions loading -> fresh data on success.
RES-016  Connectivity status labels the degraded reason.
RES-017  An Experience failure degrades to the static fallback without failing Home.
RES-018  Experience supports retry/recovery.
RES-019  Clearing the session clears the read cache (no cross-user leakage).
RES-020  Retry and degraded states log no sensitive data.
```

---

## 8. Acceptance Criteria

```text
AC-01 Retry is bounded (max 2) with exponential 300/600 ms backoff.
AC-02 Only reads/idempotent operations are retried.
AC-03 4xx/401/403/cancellation are never retried.
AC-04 The cache is in-memory and read-only, with no persistence.
AC-05 The cache fallback runs only after retry is exhausted.
AC-06 Stale data is marked via the shared Read<T> contract.
AC-07 Accounts and Movements expose explicit stale states.
AC-08 Experience degrades without failing Home (REQ-008).
AC-09 The read cache is cleared on session clear.
AC-10 Connectivity is behind an application abstraction.
AC-11 The domain does not depend on core/network.
AC-12 flutter analyze returns 0 issues and flutter test passes.
```

---

## 9. Traceability (Target)

```text
REQ-006  Limited connectivity
         -> In-memory read cache with an explicit stale/degraded state.

REQ-007  High network latency
         -> Explicit timeouts, bounded retry, and explicit loading state.

REQ-008  Partial service unavailability
         -> Failure isolation: Experience degrades without failing Home.

REQ-009  Loading, retry, cache and recovery states
         -> Explicit states plus retry/recovery transitions.

SEC-002  Sensitive data protection
         -> Cache is in-memory, cleared on session clear, never logged.
```

Traceability is updated with evidence after implementation (final commit).

---

## 10. Out of Scope

- Offline-first synchronization and conflict resolution.
- Persistent or distributed caching.
- Delta sync and background synchronization.
- Cache eviction and TTL.
- Jitter and adaptive backoff.
- Retry of non-idempotent operations.

---

## 11. Definition of Done

```text
Architecture
- Retry lives at the core/network boundary; the cache fallback lives in the read use case.
- Read<T> is a shared contract; the domain does not depend on core/network.
- Features do not import Dio or connectivity_plus directly.
- Failure isolation is preserved for Experience.

Behavior
- Retry is bounded with exponential 300/600 ms backoff.
- Reads update the cache; stale is explicit and only after retry is exhausted.
- Accounts and Movements expose stale states; Experience degrades without failing Home.

Security
- The cache is in-memory and cleared on session clear.
- No sensitive value is logged (SEC-005).

Tests
- Retry policy tests (RES-001..008) with an injected sleeper.
- Cache and stale tests (RES-009..015).
- Isolation and connectivity tests (RES-016..018).
- Session-clear and observability tests (RES-019..020).
- Deterministic; no external service required.

Validation
- flutter analyze clean; flutter test green.
- Manual validation of latency, offline, and degraded behavior.
- README and traceability updated (final commit).
```

---

## 12. CI and Safe Validation

CI validates resilience without any external service.

```text
flutter pub get -> flutter analyze -> flutter test
```

Retry delays are injected, so tests are fast and deterministic. The cache is
in-memory, so no storage or network is required in CI.

---

## 13. Manual Validation and Useful Commands

The stale path requires the cache to be populated first. Sequence:

```text
1.  Backend available
2.  Open Accounts / Movements
3.  Data loads correctly
4.  The read cache is populated
5.  Stop the backend (or point the app at an unreachable host)
6.  Run the read again
7.  Observe:
        retry 1
        300 ms
        retry 2
        600 ms
        retry 3 (final attempt)
        cache hit
        stale / degraded state
8.  Restore the backend
9.  Press Retry
10. Fresh data
```

Run against the backend to populate the cache:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

Then force the failure to observe stale/degraded:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:9
```

To observe high latency, use a backend with an artificial delay and confirm the
explicit loading state and bounded retry behavior.

---

## 14. Commit Plan

```text
1  docs(resilience): define resilience policy
2  test(resilience): define resilience contracts
3  feat(resilience): add bounded retry policy
4  feat(resilience): add in-memory read cache
5  feat(resilience): add connectivity abstraction
6  feat(accounts): add retry, cache and recovery states
7  feat(movements): add retry, cache and recovery states
8  feat(experience): make the static fallback an explicit degraded state
9  refactor(resilience): report observability for retry and degraded states
10 docs(resilience): document resilience outcome
```

Commits represent logical units of change. Each step follows SDD then TDD, and
the documentation is updated at the end (commit 10).
