# ADR-004: Resilience Policy (Retry, Cache, Connectivity)

## Status

Accepted

## Context

The MVP must handle:

- limited connectivity (REQ-006);
- high network latency (REQ-007);
- partial service unavailability (REQ-008);
- loading, retry, cache, and recovery states (REQ-009).

ADR-003 (Networking and Resilience Boundaries) established the general
architecture: Dio centralized behind `lib/core/network/`, transport error
normalization, explicit timeouts, and the placement of resilience boundaries.
ADR-003 deliberately left the concrete policy open:

> Detailed cache policy will be introduced when the corresponding MVP feature
> requires it.

PR20 is that moment. This ADR defines the concrete resilience policy that PR20
implements on top of the boundaries established by ADR-003. It does not
re-establish those boundaries and does not duplicate ADR-003.

The existing foundation this policy builds on:

- `HttpClient` (`get`, `post`) and `DioHttpClient` under `lib/core/network/`;
- a shared `Dio` with explicit connect/receive/send timeouts and the
  `AuthInterceptor`;
- `guard()` mapping `NetworkException` to `NetworkError`/`ApiError` and
  `TimeoutException` to `TimeoutError`;
- `AppError.isTransient` (true for `NetworkError` and `TimeoutError`);
- explicit sealed presentation states in Accounts, Movements, and Experience.

## Decision

PR20 applies a bounded, read-only resilience policy at the `core/network`
boundary and represents degraded outcomes explicitly in presentation. It is not
an offline-first design.

### Responsibility split

- **Retry** belongs to the network boundary (a Dio interceptor over `onError`).
- **Cache fallback** belongs to the **read use case** (the repository). By the
  time the repository observes a failure, retry has already been exhausted.

```text
Read use case (repository)
        |
        v
HttpClient -> Dio -> Auth -> Retry -> remote
        |
        +-- success --------------> update read cache -----> Read(source: remote)
        |
        +-- exhausted failure ----> cache lookup
                                     |
                                     +-- hit  -> Read(source: cache)  [stale]
                                     |
                                     +-- miss -> Failure(error)
```

The cache never participates in the retry decision and the retry policy never
depends on the cache.

### Retry

- At most **2 retries** (3 attempts total).
- **Exponential backoff**: 300 ms, then 600 ms.
- Retryable: transient transport failures (connect/send/receive timeout,
  connection error) and selected `5xx` (`502`, `503`, `504`).
- Not retryable: any `4xx`, `401`, `403`, request cancellation, and
  non-idempotent operations (`POST`).
- Only **reads / idempotent** operations (`GET`).
- Retry is bounded; when exhausted, the original mapped error is surfaced to the
  caller.
- Implemented as a Dio interceptor over `onError`, with an injectable delay so
  tests are deterministic and fast.
- No jitter (deterministic); jitter is a future enhancement.

### Cache

- A **reusable in-memory read cache** (`ReadCache`) under `core/network/`.
- **In-memory** only; no persistence.
- **`GET`/read** only.
- A **last-known-good fallback**: a fresh remote response always wins; cached
  data is used only when the remote read fails after retry is exhausted.
- **No TTL** (the cache is a fallback, not a time-based cache).
- The **read use case** decides whether to serve stale data, so the fallback is
  explicit and testable.
- The cache is cleared when the session is cleared (logout / `401`) to prevent
  cross-user data leakage.
- Not offline-first: no writes, no background sync, no conflict resolution.

### Read contract

Staleness is carried by a shared application/domain contract, not by an
infrastructure type:

```text
Read<T> { T data; ReadSource source; }   // remote | cache
```

`Read<T>` lives under `lib/shared/`. The domain and features depend on `shared`,
never on `core/network` for this contract. This preserves the dependency
direction established by ADR-001 and ADR-003:

```text
features -> shared contract <- core/network implementation
```

### Connectivity

- An application-defined abstraction in `core/network/`; `connectivity_plus` is
  used only as an infrastructure adapter behind it.
- Connectivity is **observational**: it labels the degraded reason and supports
  an accurate degraded message. It does not gate requests.
- `connectivity_plus` only reports a link state; a Wi-Fi/mobile link does not
  guarantee reachability. Timeouts and HTTP errors remain the authority on
  whether a request succeeded.
- Recovery is a **user-initiated retry**; there is no automatic background
  refetch.

### Failure Isolation

A failure in an optional or secondary service must not fail the core journey
(REQ-008). Experience degrades to its static Home fallback and does not fail
Home.

### States

Existing:

```text
initial
   |
   v
loading
   |
   +--> loaded
   |
   +--> empty
   |
   +--> failure
```

Extended by PR20:

```text
failure
   |
   v
 retry  (user-initiated)
   |
   v
recovery
```

and, when cached data exists:

```text
loading
   |
   v
remote failure (retry exhausted)
   |
   v
cached data
   |
   v
stale / degraded
   |
   v
 retry
   |
   v
fresh data
```

`stale`/`degraded` is an explicit state, not a silent substitution. Retry and
recovery are transitions initiated by the user through presentation.

## Alternatives Considered

### A third-party retry package (e.g. `dio_smart_retry`)

Rejected. The policy is small, must be deterministic and testable, and ADR-003
keeps external packages inside `core/network`. A package adds coupling without
additional value.

### Retry at the feature or repository layer

Rejected. It duplicates the policy across features and couples business code to
transport semantics.

### Cache as a Dio interceptor

Rejected. An interceptor that resolves errors on `onError` makes the ordering
against the retry interceptor hard to guarantee and risks serving stale data
before retry is exhausted. It also forces the cache to know the retry policy.
The fallback instead belongs to the read use case, which runs only after retry
is exhausted.

### `Read<T>` under `core/network`

Rejected. It would make the domain/application depend on an infrastructure
module. `Read<T>` is a shared contract and lives under `lib/shared/`.

### Persistent / offline-first cache (SQLite, Hive, etc.)

Rejected. Out of scope for the MVP; it introduces synchronization and
conflict-resolution surface that PR20 explicitly excludes.

### No cache

Rejected. REQ-006 and REQ-009 require degraded data availability.

### TTL-based cache

Rejected. A fresh remote response always wins, so a TTL adds complexity without
benefit for a fallback-only cache.

### Using `connectivity_plus` directly in features

Rejected. It violates the dependency rule; it is wrapped behind an
application-defined interface.

### Automatic refetch when connectivity is restored

Rejected. It edges into offline-first synchronization semantics. Recovery is
explicit and user-initiated.

## Trade-offs

### Benefits

- One bounded, centralized retry policy.
- The cache fallback is explicit in the read use case and cannot race the retry.
- Deterministic, fast tests through injected delays.
- The domain depends only on a shared contract, not on infrastructure.
- Features remain independent of Dio and of `connectivity_plus`.
- Failure isolation is preserved for optional services.

### Costs

- Adds a retry interceptor and a read cache to `core/network`.
- Adds a shared `Read<T>` contract.
- Adds explicit states to Accounts and Movements.
- The cache must be invalidated on session clear to avoid cross-user leakage.

## Scope Boundary

This ADR defines the concrete retry, cache, connectivity, and degraded-state
policy for the MVP. It does not define:

- offline-first synchronization;
- persistent or distributed caching;
- conflict resolution or delta sync;
- background synchronization;
- cache eviction or TTL;
- jitter or adaptive backoff;
- multi-user cache partitioning beyond clearing on session clear.

Those decisions will be documented only when a product requirement makes them
necessary.

## Long-term Impact

The retry policy is isolated at the network boundary, and the cache fallback is
owned by the read use case. Additional financial features can opt into the same
retry behavior and read cache without redefining the policy, and the policy can
be replaced or extended (persistence, sync, jitter) without changing business
rules or the domain contract.
