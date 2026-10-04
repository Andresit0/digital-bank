# ADR-009: Observability and Monitoring

## Status

Accepted

## Context

The MVP must be able to detect and diagnose operational issues during
development and, eventually, in production (REQ-013). The evaluation criterion
EC-002 treats observability as part of engineering quality, and SEC-005 requires
that sensitive data is never exposed in logs or telemetry.

PR12 introduced `ILogger` / `DevLogger` as a development logging seam. That seam
is appropriate for local diagnostics, but it is not a production observability
boundary: it has no event taxonomy, no severity model, and no provider-agnostic
extension point. Without such a boundary, features would either have no way to
report operational events or would have to depend on a concrete provider.

A concrete external provider (Crashlytics, Sentry, Firebase, etc.) must not be a
prerequisite for the MVP, and the test suite must not require a provider SDK.

## Decision

Introduce a provider-agnostic production observability seam, separate from
development logging.

```text
Development diagnostics        Production telemetry
      ILogger                        IObservability
         |                                |
     DevLogger                    provider / adapter
                                       /        \
                                    Noop     External provider (future)
```

- `IObservability` in `lib/shared/interfaces/` exposes
  `void report(ObservabilityEvent event)`.
- `ObservabilityEvent` and `ObservabilitySeverity` live in
  `lib/shared/observability/` (pure Dart).
- `NoopObservability` (default) and `observabilityProvider` live in
  `lib/core/services/observability/`.
- An adapter is the extension point to a concrete provider. PR14 does not
  integrate any external provider.
- `ILogger` remains available for development diagnostics. A reportable failure
  is reported exactly once, through `IObservability`; the corresponding
  `ILogger.error` call is not made, to avoid double reporting.

### Event taxonomy

| Event | Severity | Owner |
|---|---|---|
| `app_started` | info | shared |
| `app_startup_failed` | fatal | shared |
| `network_failure` | warning | shared |
| `app_error` | error | shared |
| `auth_login_failed` | warning | auth |
| `auth_logout` | info | auth |
| `accounts_load_failed` | warning | accounts |
| `movements_load_failed` | warning | movements |

Event names are plain strings. Shared owns the generic names; each feature owns
its namespace (`auth_*`, `accounts_*`), so `shared` does not depend on features.

### Sensitive data policy (SEC-005)

Allowed metadata keys: `errorType`, `statusCode`, `endpoint` (path without
query), `feature`, `attempt`.

Never present in an event name or metadata: passwords, access/refresh tokens,
full account numbers, `maskedNumber`, balances, email or other PII, credentials,
or full payloads. `ObservabilityEvent` never carries raw `error` or `stackTrace`.

### Testing and composition

- `observabilityProvider` resolves `NoopObservability` by default and is the
  composition/testing seam.
- Tests override the provider with an in-memory `FakeObservability`; no network
  and no provider SDK are used.
- An architecture test (`OBS-ARCH-001`) forbids features from importing concrete
  observability implementations; features may import only the seam and the
  shared contracts.

## Alternatives Considered

### Extend `ILogger` with event methods

Rejected. It mixes development diagnostics (free text, stack traces) with
production telemetry (typed events, severity, provider routing) and turns
`ILogger` into a single large interface.

### Integrate a concrete provider inside features

Rejected. It couples features to a vendor, prevents testing without the SDK, and
duplicates provider setup across features.

### No observability seam

Rejected. REQ-013 could not be evidenced, and production issues could not be
detected or diagnosed through a stable boundary.

## Trade-offs

### Benefits

- Clear separation between development logging and production telemetry.
- Provider-agnostic: a provider can be attached later without touching features.
- Testable without an external provider SDK.
- Event taxonomy and sensitive-data policy are explicit and enforced by tests.
- Preserves the dependency direction `shared <- core <- features`.

### Costs

- One additional abstraction.
- By default the seam is a no-op, so there is no live monitoring until a
  provider adapter is integrated.
- No distributed tracing, correlation IDs, or performance metrics yet.

## Long-term Impact

A production observability provider can be integrated by implementing
`IObservability` in an adapter and overriding `observabilityProvider` at the
composition root, without changes to Auth, Accounts, or future features.
Navigation, product analytics, performance metrics, and distributed tracing
remain future work and are documented as out of scope for PR14.

## Relation to ADR-003

ADR-003 establishes the error boundary: transport failures are converted by
`guard()` into `AppError` and surfaced to presentation state. ADR-009 consumes
those `AppError`s at the Notifier boundary and reports operational events. The
two decisions are complementary: ADR-003 defines how failures are represented;
ADR-009 defines how reportable failures are observed.
