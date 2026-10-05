# PR21 — Onboarding (Minimum Viable Onboarding)

## Document Information

| Field | Value |
|---|---|
| Project | Digital Financial Platform — Flutter Technical Assessment |
| Document | PR21 Specification — Onboarding |
| Status | Frozen (approved) |
| Related ADR | ADR-001 (Feature-first Clean Architecture), ADR-002 (State Management), ADR-009 (Observability), ADR-010 (Local Persistence) |
| Related Requirements | REQ-001 (onboarding and authentication), REQ-009 (loading/recovery behavior), REQ-010, REQ-011, REQ-012, REQ-023, REQ-025, SEC-002 |
| Depends on | Authentication and guarded routing (`features/auth`), shared error model (PR12), production observability (PR14), resilience policy (PR20) |
| Scope | New `features/onboarding` feature and a new generic `core/storage` seam; router startup gate |
| Platform | Flutter (all platforms) |

---

## 1. Purpose

Present a brief, controlled onboarding experience to a new customer before
authentication and remember that it was completed, so it is not shown again on
subsequent launches, without altering the existing Login -> Home journey.

---

## 2. Frozen Decisions

| ID | Decision |
|---|---|
| D1 | Local persistence via `shared_preferences`. |
| D2 | Use `SharedPreferencesAsync`, not the legacy API. |
| D3 | The plugin is isolated behind `KeyValueStore`. |
| D4 | `core/storage` contains only generic infrastructure. |
| D5 | `OnboardingRepository` belongs to `features/onboarding`. |
| D6 | `OnboardingLocalDataSource` uses `KeyValueStore`. |
| D6′ | The feature uses `infrastructure/` (not `data/`), matching every existing feature. |
| D7 | The persisted state is `onboarding_completed`. |
| D8 | `/` remains the bootstrap route. |
| D9 | Bootstrap resolves the onboarding state asynchronously. |
| D10 | The existing redirect remains synchronous. |
| D11 | `onboarding_completed = true` allows entry to Login. |
| D12 | Logout returns to Login, never to Onboarding. |
| D13 | Onboarding state survives logout and restart while the preference remains available. |
| D14 | There is no onboarding backend. |
| D15 | There is no cross-device synchronization. |
| D16 | SDD follows the PR20 pattern. |
| D17 | Existing auth/product tests may override onboarding as completed. |
| D18 | `OnboardingRepository` uses `Future<Result<bool>> isCompleted()` / `Future<Result<void>> complete()`, following the project `Result`/`AppError` contract. |
| D18′ | The data source returns raw `Future<bool>` / `Future<void>`; the repository applies `guard(...)`. |
| D19 | Skip is equivalent to completing and persists `onboarding_completed = true`. |
| D20 | `onboarding_storage_failed` is reported by the notifier (repositories return `Result`); no product analytics. |
| D21 | Three pages, English, consistent with the current application. |
| D22 | PR21 adds a dedicated onboarding E2E. |
| D23 | No analytics, remote config, feature flags, or personalization inside PR21. |

Dependency direction remains:

```text
shared  <-  core  <-  features
```

---

## 3. Scope Boundaries

In scope: first-run experience, three steps, Next/Skip, progress, completion,
minimal local persistence, and a bootstrap routing gate.

Out of scope: registration, password recovery, biometrics, complex interactive
tutorials, profile-based personalization, an onboarding backend, CMS,
onboarding analytics, feature flags, remote configuration, and cross-device
synchronization.

---

## 4. Flow

```text
bootstrap /
    |
    | resolve isCompleted()  (async)
    v
not completed -------------------------> /onboarding
                                            |
                                    Page 1 -> Page 2 -> Page 3
                                       |         |         |
                                       +---------+---------+-- Skip
                                            |
                                    onboarding_completed = true
                                            |
                                            v
                                          /login
completed + not authenticated ----------> /login
authenticated --------------------------> /home
authenticated -> logout ----------------> /login   (never /onboarding)
```

---

## 5. Contracts

### 5.1 Storage (`lib/core/storage/`)

```dart
abstract interface class KeyValueStore {
  Future<bool?> getBool(String key);
  Future<void> setBool(String key, bool value);
}
```

`SharedPreferencesKeyValueStore` implements it over `SharedPreferencesAsync`.
Only `core/storage` imports `package:shared_preferences`.

### 5.2 Domain (`lib/features/onboarding/domain/`)

```dart
abstract interface class OnboardingRepository {
  Future<Result<bool>> isCompleted();
  Future<Result<void>> complete();
}
```

- `Success(true)` -> onboarding completed; `Success(false)` -> onboarding required.
- Read failure -> `Failure(AppError)`; the notifier marks onboarding required and
  reports `onboarding_storage_failed`.
- Write failure -> `Failure(AppError)`; the notifier stays required (no
  navigation) and reports `onboarding_storage_failed`.
- The repository applies `guard(...)` and is free of observability.

### 5.3 Data source (`lib/features/onboarding/infrastructure/`)

```dart
abstract interface class OnboardingLocalDataSource {
  Future<bool> isCompleted();
  Future<void> markCompleted();
}
```

- Key: `onboarding_completed` (private constant).
- `null` is mapped to `false`.

### 5.4 Presentation states

```text
OnboardingInitial
    |
    v
OnboardingRequired -- complete()/skip() --> OnboardingCompleted
```

### 5.5 Routing

- New `AppRoute.onboarding` at `/onboarding`.
- Bootstrap resolves completion; the redirect stays synchronous via a refresh
  listenable that reflects onboarding + auth, as auth already does.

### 5.6 Observability

- Only `onboarding_storage_failed` (warning), reported by the notifier, with
  minimal non-sensitive metadata (`errorType`). No
  `onboarding_started`/`_skipped`/`_completed`.

---

## 6. Content (D21)

```text
Page 1  Your money, in one place   -> Accounts, Balances, Movements
Page 2  A smarter experience       -> Personalized experience, Dynamic content
Page 3  Stay informed              -> Notifications, Activity
```

`Page 1 -> Page 2 -> Page 3 -> Get started`; `Skip` is available from the
initial pages and produces the same persisted state as `Get started`.

---

## 7. Scenarios

```text
ONB-001  A new customer sees onboarding before authentication.
ONB-002  Onboarding explains the application purpose across three steps.
ONB-003  Next advances; Skip completes.
ONB-004  A progress indicator reflects the current step.
ONB-005  Onboarding can be completed.
ONB-006  Completion persists onboarding_completed = true.
ONB-007  A completed onboarding is not shown again on a subsequent launch.
ONB-008  Completion navigates to login.
ONB-009  Login -> Home is intact; logout returns to login.
ONB-010  Completion survives logout and subsequent launches while the preference remains available.
ONB-011  The feature never imports the storage plugin.
ONB-012  Onboarding controls expose semantic labels, respect text scaling, maintain accessible contrast, and use appropriate touch targets.
```

---

## 8. Acceptance Criteria

```text
AC-01 Onboarding is shown before login until completion is persisted.
AC-02 Three steps with Next, Skip, and a progress indicator.
AC-03 Completion and Skip both persist onboarding_completed = true.
AC-04 Bootstrap resolves completion asynchronously; the redirect stays synchronous.
AC-05 Completed + unauthenticated -> login; authenticated -> home.
AC-06 Logout returns to login, never to onboarding.
AC-07 Only core/storage imports shared_preferences.
AC-08 Storage failures are non-fatal and reported as onboarding_storage_failed.
AC-09 flutter analyze returns 0 issues and flutter test passes.
AC-10 Accessibility requirements are satisfied for onboarding controls (ONB-012).
```

---

## 9. Traceability (Target)

```text
REQ-001  Customer onboarding and authentication
         -> Onboarding feature (completion gate) + existing authentication.
REQ-009  Loading/recovery behavior
         -> Bootstrap exposes an explicit initial/resolving state while onboarding completion is loaded.
REQ-012  Critical end-to-end flow
         -> Onboarding -> Login -> Home E2E.
REQ-025  Accessible UI
         -> Onboarding controls expose semantic labels, respect text scaling, maintain contrast, and use appropriate touch targets (ONB-012).
SEC-002  Sensitive data protection
         -> Only a boolean is persisted; no sensitive data.
```

Traceability is updated with evidence in the final commit.

---

## 10. Out of Scope

- Registration, password recovery, biometrics.
- Complex interactive tutorials and profile-based personalization.
- Onboarding backend, CMS, feature flags, remote configuration.
- Onboarding/product analytics and cross-device synchronization.

---

## 11. Definition of Done

```text
Architecture
- core/storage holds only generic infrastructure; the plugin is isolated.
- The domain does not import Flutter, core/storage, or shared_preferences.
- The redirect remains synchronous; bootstrap resolves asynchronously.

Behavior
- New install -> onboarding; completed -> login; logout -> login.
- Next/Skip/progress behave as specified.

Security
- Only onboarding_completed is persisted; nothing sensitive is logged.

Tests
- Unit (repository, data source, notifier), widget (screen), routing, and E2E.
- Deterministic; no network or external service.

Validation
- flutter analyze clean; flutter test green; onboarding E2E green.
- README and traceability updated (final commit).
```

---

## 12. CI and Safe Validation

```text
flutter pub get -> flutter analyze -> flutter test
```

No backend, network, or secrets are required; storage is faked in tests.

---

## 13. Commit Plan

```text
1  docs(onboarding): define onboarding policy
2  test(onboarding): define onboarding contracts
3  feat(onboarding): add KeyValueStore storage seam
4  feat(onboarding): add repository and data source
5  feat(onboarding): add onboarding state and screen
6  feat(onboarding): gate startup routing on onboarding completion
7  docs(onboarding): finalize onboarding documentation
```
