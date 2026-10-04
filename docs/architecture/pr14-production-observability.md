# PR14 — Production Observability

## Document Information

| Field | Value |
|---|---|
| Project | Digital Financial Platform — Flutter Technical Assessment |
| Document | PR14 Specification — Production Observability |
| Status | Frozen (approved) |
| Related ADR | ADR-003 (Networking and Resilience Boundaries), ADR-009 (Observability and Monitoring) |
| Related Requirements | REQ-013, REQ-022, SEC-005 |
| Depends on | PR12 (Error Handling and Development Logging) |
| Scope | Cross-cutting (shared + core), feature reporting limited to Auth and Accounts |

---

## 1. Purpose

Evolve the seam introduced by PR12 (`ILogger`) toward production observability
without duplicating the development logging mechanism and without coupling
features to a concrete provider.

- PR12 = development logging (`ILogger` / `DevLogger`).
- PR14 = production observability (`IObservability`) as a provider-agnostic seam.

---

## 2. Relation to PR12

```text
PR12                                        PR14
ILogger  ->  DevLogger                      IObservability  ->  adapter  ->  Noop | Provider
(development, free text + stack trace)      (production, typed events + safe metadata)
```

`ILogger` is preserved unchanged. `IObservability` is the new production
boundary. A single reportable Notifier failure is reported exactly once, through
`IObservability`; the corresponding `ILogger.error` call is removed. `ILogger`
remains available for other development diagnostics.

---

## 3. Frozen Decisions

| ID | Decision |
|---|---|
| D1 | New `IObservability` interface; `ILogger` remains for development diagnostics. |
| D2 | Provider-agnostic: `NoopObservability` by default; an adapter is the extension point; no external dependency. |
| D3 | PR14 includes ADR-009 and `docs/operations/README.md`. |
| D4 | Event taxonomy limited to errors and key lifecycle events. |
| L1 | `ObservabilityEvent` + `ObservabilitySeverity` live in `lib/shared/observability/`; `IObservability` in `lib/shared/interfaces/`; implementations and provider in `lib/core/services/observability/`. |
| L2 | The Notifier reports a reportable failure once via `IObservability`; the `ILogger.error` for that same failure is removed. |
| L3 | Event `name` is a `String`; shared owns generic names, Auth/Accounts own their `auth_*` / `accounts_*` names. |
| L4 | `AppConfig` is not modified; `observabilityProvider` is the composition/testing seam. |
| L5 | Sensitive-data control is policy + tests in PR14; no runtime allowlist helper yet. |

Dependency direction remains:

```text
shared  <-  core  <-  features
```

`shared` never depends on `core` or on any feature.

---

## 4. Contracts

### 4.1 `lib/shared/observability/observability_severity.dart`

```dart
enum ObservabilitySeverity { debug, info, warning, error, fatal }
```

### 4.2 `lib/shared/observability/observability_event.dart`

```dart
import 'observability_severity.dart';

class ObservabilityEvent {
  const ObservabilityEvent({
    required this.name,
    required this.severity,
    this.metadata = const <String, Object?>{},
    this.timestamp,
  });

  final String name;
  final ObservabilitySeverity severity;
  final Map<String, Object?> metadata;
  final DateTime? timestamp;
}
```

`timestamp` is optional. Producers are not required to provide it. When it is
null, the event represents an event without a producer-defined timestamp; a
consumer may stamp it at report time.

### 4.3 `lib/shared/interfaces/i_observability.dart`

```dart
import '../observability/observability_event.dart';

abstract interface class IObservability {
  void report(ObservabilityEvent event);
}
```

### 4.4 `lib/core/services/observability/`

```text
noop_observability.dart       class NoopObservability implements IObservability
observability_provider.dart   final observabilityProvider = Provider<IObservability>((ref) => const NoopObservability());
```

`NoopObservability.report` does nothing and has no side effects.

---

## 5. Event Taxonomy

| Event | Severity | Trigger | Allowed metadata |
|---|---|---|---|
| `app_started` | info | application boot | — |
| `app_startup_failed` | fatal | startup failure | `errorType` |
| `auth_login_failed` | warning | `Failure` on login | `errorType`, `statusCode` |
| `auth_logout` | info | logout | — |
| `network_failure` | warning | network failure not bound to a feature | `errorType`, `statusCode` |
| `app_error` | error | `UnexpectedError` | `errorType` |

Anti-duplication precedence: a network login failure emits only
`auth_login_failed`; `network_failure` is reserved for global/feature-agnostic
network issues.

Event names are plain strings. Shared owns the generic names
(`app_started`, `app_startup_failed`, `network_failure`, `app_error`); Auth owns
`auth_login_failed` / `auth_logout`; Accounts owns its own names.

---

## 6. Metadata and Sensitive Data (SEC-005)

Allowed metadata keys: `errorType`, `statusCode`, `endpoint` (path without
query), `feature`, `attempt`.

Never present in `name` or `metadata`:

- passwords;
- access tokens or refresh tokens;
- full account numbers;
- `maskedNumber` (an existing `Account` field; explicitly treated as sensitive);
- balances;
- email or other PII;
- credentials;
- full payloads.

`ObservabilityEvent` never carries raw `error` or `stackTrace`. Producers map
failures to `errorType`. This policy is enforced by tests that assert the
observable result (reported events), not merely that a producer avoided building
a value.

---

## 7. Configuration

PR14 does not modify `AppConfig`. Observability is composed through
`observabilityProvider`, which resolves `NoopObservability` by default and can
be overridden in the composition root and in tests.

---

## 8. Testing Strategy

- `FakeObservability implements IObservability`, in-memory, captures reported
  events; it is a test double and never production code.
- `NoopObservability` produces no effects.
- Tests override `observabilityProvider` via `ProviderContainer` / `ProviderScope`.
- No network and no external provider are used.

---

## 9. Scenarios

```text
OBS-001 ObservabilityEvent exposes name, severity, and metadata
OBS-002 defaults: metadata is empty; timestamp is optional
OBS-003 ObservabilitySeverity covers debug, info, warning, error, fatal

OBS-010 NoopObservability.report does not throw and has no side effects
OBS-011 observabilityProvider resolves an IObservability (Noop by default)

SEC-OBS-001 From the reported events, no prohibited metadata key is present
SEC-OBS-002 From the reported events, no sensitive value is present
            (token, full account number, maskedNumber, balance, email)

OBS-ARCH-001 No file under lib/features imports NoopObservability,
             the observability provider implementation, or any concrete
             provider. Features may import IObservability, ObservabilityEvent,
             and ObservabilitySeverity.

OBS-INT-AUTH-001 auth_login_failed reported on Failure(ApiError 401)
OBS-INT-AUTH-002 auth_login_failed reported on Failure(NetworkError)
OBS-INT-AUTH-003 auth_logout reported on logout

OBS-INT-ACC-001 accounts load failure reported on Failure
```

SEC-OBS-001 and SEC-OBS-002 assert the policy from the observable result (the
captured events), not by inspecting producer internals.

---

## 10. Acceptance Criteria

```text
AC-01 Features depend on IObservability, never on a concrete provider.
AC-02 A reportable Notifier failure produces exactly one event (no double reporting).
AC-03 No sensitive data is reported (SEC-005), including maskedNumber.
AC-04 NoopObservability produces no external effects.
AC-05 observabilityProvider is overridable in tests.
AC-06 No new dependency is introduced.
AC-07 flutter analyze returns 0 issues and flutter test passes.
```

---

## 11. Traceability

```text
REQ-013 -> ADR-009 -> IObservability -> Auth / Accounts -> tests -> Operations -> evidence
REQ-022 (engineering quality and observability)
SEC-005 (no sensitive data in logs/telemetry)
```

---

## 12. Out of Scope

Navigation, product analytics, A/B testing, performance metrics, distributed
tracing, full correlation IDs, retry/cache/offline, movements, personalization,
external service, notifications, push, and any concrete provider integration.
These belong to later work and are not part of PR14.

---

## 13. Definition of Done

```text
1. Spec approved and frozen.
2. RED tests for the observability contracts and scenarios.
3. GREEN: IObservability, ObservabilityEvent, ObservabilitySeverity,
   NoopObservability, observabilityProvider.
4. Integration coverage for provider wiring and observable behavior.
5. Auth integrated with IObservability (Commit 5).
6. Accounts integrated with IObservability (Commit 6).
7. ADR-009, docs/operations/README.md, and traceability updated (Commit 7).
8. flutter analyze clean and flutter test green.
9. Diff reviewed. Commit and push only on explicit instruction.
```

---

## 14. Commit Plan

```text
1 docs(observability): define production observability specification
2 test(observability): define observability contracts and scenarios
3 feat(observability): add production observability foundation
4 test(observability): add observability integration coverage
5 refactor(auth): report production observability events
6 refactor(accounts): report production observability events
7 docs(observability): document monitoring and traceability
```
