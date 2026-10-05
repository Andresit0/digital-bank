# Operations

## CI Quality Gate

The project runs `flutter analyze` and `flutter test` (unit, widget, and
integration-style) as its quality gate. End-to-end flows run on a device or
simulator (`flutter test integration_test/... -d <device-id>`).

For the build, deployment, release, and rollback strategy, and the current
automation status, see
[Deployment and Operations](../delivery/deployment-and-operations.md).

## Observability and Monitoring

### Model

```text
Application
    |
    v
IObservability
    |
    v
Provider / adapter seam
    |
    v
External observability provider (future)
```

PR14 establishes the provider-agnostic observability seam. By default it
resolves `NoopObservability`, so no event leaves the application. No external
observability provider is integrated in PR14.

### Events produced

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
| `request_retried` | info | resilience/network |
| `accounts_stale_served` | warning | accounts |
| `movements_stale_served` | warning | movements |
| `experience_degraded` | warning | experience |

### Information that may be observed

Event name, severity, and the allowlisted metadata keys:

```text
errorType
statusCode
endpoint (path without query)
feature
attempt
```

### Information that must never be observed

Passwords, access or refresh tokens, full account numbers, `maskedNumber`,
balances, email or other PII, credentials, and full payloads. Events never carry
raw error objects or stack traces; producers map failures to `errorType`.

### Resilience events (PR20)

PR20 introduces four resilience events on the same seam:

| Event | Severity | Owner | Metadata |
|---|---|---|---|
| `request_retried` | info | resilience/network | `attempt`, `endpoint` (path without query) |
| `accounts_stale_served` | warning | accounts | `source=cache` |
| `movements_stale_served` | warning | movements | `source=cache` |
| `experience_degraded` | warning | experience | `errorType`, `statusCode` (when available) |

`request_retried` is emitted once per retry actually decided, not once per
error. `accounts_stale_served` and `movements_stale_served` indicate that usable
data was served from the in-memory read cache after the remote read failed.

`source=cache` is a controlled resilience metadata value added by PR20. It is
documented here explicitly beyond the historical PR14 allowlist (the allowlist
above remains the PR14 baseline). These resilience events never contain
credentials, tokens, `Authorization` headers, request bodies, or financial data.

### Replacing `NoopObservability`

Implement `IObservability` in a provider adapter and override
`observabilityProvider` at the composition root. Features do not change, because
they depend on the `IObservability` contract and the provider seam only.

### Testing a real integration

Tests use an in-memory `FakeObservability` and override `observabilityProvider`;
they assert the reported events without any network or provider SDK. A real
provider integration would be validated by overriding the provider in the
composition root and asserting that the adapter receives the same events that
the fake receives today.

### Out of scope for PR14

A concrete external provider, navigation and product analytics, performance
metrics, distributed tracing, full correlation IDs, and retry/cache/offline
behavior.

Retry/cache/offline resilience and the corresponding resilience events are now
covered by PR20 (`docs/architecture/pr20-resilience.md`); the PR14 scope above
is preserved as the historical baseline.

### Incident response

The operational signals are the reportable events above. With a provider adapter
in place they would feed alerting and incident workflows. Until such an adapter
is integrated, the seam is a no-op and no signal is transmitted externally.
