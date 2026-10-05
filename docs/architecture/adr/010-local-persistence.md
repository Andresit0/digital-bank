# ADR-010: Local Persistence (Onboarding Completion)

## Status

Accepted

## Context

REQ-001 requires customer onboarding and authentication. PR21 introduces an
onboarding experience shown before authentication that must be remembered so it
is not shown again on subsequent launches (ONB-001..ONB-010).

The project currently has no local persistence: `SessionManager` is in-memory
only, and no storage dependency exists. Persisting a single boolean therefore
requires introducing a storage mechanism, and a third-party plugin must not
become a dependency of the domain or of the feature (ADR-001, ADR-003).

The value to persist is not a credential or a financial datum. SEC-004 (secure
credential storage) is a separate concern and remains deferred; ADR-008 governs
secrets and sensitive data.

## Decision

Persist the onboarding completion flag locally using `shared_preferences`,
through its modern `SharedPreferencesAsync` API, isolated behind a generic
`KeyValueStore` seam in `core/storage`.

```text
Third-party persistence
        |
        v
SharedPreferencesAsync
        |
        v
SharedPreferencesKeyValueStore   (core/storage, infrastructure adapter)
        |
        v
KeyValueStore                    (core/storage, application contract)
        |
        v
OnboardingLocalDataSource        (features/onboarding/infrastructure)
        |
        v
OnboardingRepository             (features/onboarding/domain)
        |
        v
OnboardingNotifier               (features/onboarding/presentation)
```

- `KeyValueStore` is generic infrastructure and contains no onboarding knowledge:

  ```dart
  abstract interface class KeyValueStore {
    Future<bool?> getBool(String key);
    Future<void> setBool(String key, bool value);
  }
  ```

- `SharedPreferencesKeyValueStore` is the only place that imports
  `package:shared_preferences`. It uses `SharedPreferencesAsync` (not the legacy
  `SharedPreferences` API), which performs asynchronous reads and writes without a
  local in-memory cache.
- The persisted key is `onboarding_completed` (a private constant of
  `OnboardingLocalDataSource`), not part of global configuration.
- `SharedPreferencesAsync` supports `bool` directly, so no custom serialization
  is introduced.
- Read semantics: an absent value is treated as `false` (onboarding required); a
  read failure is surfaced as `Failure(AppError)` by the repository and the
  notifier treats it as required.
- Write semantics: a write failure is surfaced as `Failure(AppError)`; the
  notifier does not mark completion, so the UI does not navigate to login until
  the write has succeeded.
- Observability: the notifier reports `onboarding_storage_failed` through
  `IObservability` (ADR-009) with minimal, non-sensitive metadata; the repository
  stays pure.

Only `bool` accessors are introduced. `getString`, `getInt`, `remove`, and
`clear` are deliberately omitted until a demonstrated need exists.

## Alternatives Considered

### Legacy `SharedPreferences` API

Rejected. The plugin's documentation recommends `SharedPreferencesAsync` or
`SharedPreferencesWithCache` for new code; `SharedPreferences` is the legacy API
and maintains an in-memory cache that is unnecessary here.

### `SharedPreferencesWithCache`

Rejected. It is designed to avoid repeated platform reads by caching. PR21 reads
a single boolean once at startup, so a cache adds no value.

### `flutter_secure_storage`

Rejected. `onboarding_completed` is neither a credential nor a secret. Secure
storage is reserved for SEC-004, which remains deferred.

### `sembast` / `hive` / `isar`

Rejected. A full embedded database is disproportionate for a single boolean and
adds surface, dependencies, and lifecycle management without benefit.

### A file-based store

Rejected. It requires path handling and serialization that `shared_preferences`
already provides, with no added value.

### No persistence (in-memory only)

Rejected. ONB-007 requires that onboarding not reappear on subsequent launches;
in-memory state cannot satisfy it.

### Storing the decision inside a widget

Rejected. It couples UI to persistence and violates the separation required by
ADR-001 and ADR-003.

## Trade-offs

### Benefits

- One new dependency, isolated behind a generic contract.
- The domain and the feature never import the plugin.
- Deterministic and testable: `KeyValueStore` is replaced by a fake in tests.
- Minimal contract (`bool` only), matching the actual need.
- Uses the API recommended by the plugin for new code.

### Costs

- One new dependency and one new `core/storage` module.
- `shared_preferences` is intended for simple data and is not a durable or
  critical-data store; the completion flag is acceptable under that constraint.
- A storage read/write failure must be handled explicitly (surfaced as
  `Failure(AppError)` through the repository, reported by the notifier, and never
  silently ignored).

## Scope Boundary

This ADR defines local persistence only for the onboarding completion flag. It
does not define:

- session or credential persistence (SEC-004 remains deferred);
- caching of network data (governed by ADR-004, in-memory only);
- cross-device synchronization (explicitly out of scope, D15);
- a general-purpose key-value store beyond `bool`.

## Long-term Impact

A future requirement can extend `KeyValueStore` (for example, `remove`/`clear`
or string accessors) without changing the feature, or replace the adapter with
another mechanism by overriding the `core/storage` provider. The dependency
direction `shared <- core <- features` is preserved, and no feature depends on
`shared_preferences` directly.
