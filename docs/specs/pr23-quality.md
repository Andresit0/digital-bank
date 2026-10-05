# PR23 — Final Quality & Evidence

## Document Information

| Field | Value |
|---|---|
| Project | Digital Financial Platform — Flutter Technical Assessment |
| Document | PR23 Specification — Final Quality & Evidence |
| Status | Frozen (approved) |
| Depends on | PR22 delivery documentation (`docs/delivery/`), the existing tests, and the existing workflows |
| Scope | Final regression, quality gates, E2E gaps, screenshot automation, and CI artifacts |
| Platform | Flutter (Android/iOS) and NestJS API |

---

## 1. Purpose

This specification defines how PR23 converts the current project state into
reproducible final evidence for:

- regression;
- quality gates;
- E2E;
- visual evidence;
- CI artifacts.

PR23 adds **no product functionality**. It is the phase that turns the PR22
strategy into executable evidence. This document is the specification only; it
does not implement tests, screenshots, or workflows.

---

## 2. Initial State (Real)

The current state, as inspected, is the starting point. No CI artifact or
screenshot infrastructure exists today.

### 2.1 `flutter-ci.yml`

- Trigger: `pull_request` → `main`.
- Steps: secret guard, Flutter setup, `flutter pub get`, `flutter analyze`,
  `flutter test`, `flutter build apk --debug`.
- No integration tests.
- No artifacts.

### 2.2 `api-ci.yml`

- Trigger: `pull_request` → `main` (paths `api/**`).
- Node.js 24, `npm ci`, `npm run build`, `npm run lint`, `npm run test`.
- No artifacts.

### 2.3 `integration_test/`

- 9 end-to-end tests.
- 2 support helpers (`integration_test/support/api_http_server.dart`,
  `integration_test/support/onboarding_test_support.dart`).
- No screenshot infrastructure.

### 2.4 Not present today

Screenshot capture, a screenshot/E2E workflow, workflow artifacts, and signed
release builds do not exist. PR23 must not describe them as existing.

---

## 3. E2E Inventory

The nine existing end-to-end tests are:

| Area | Test |
|---|---|
| Onboarding | `integration_test/onboarding/onboarding_flow_test.dart` |
| Auth | `integration_test/auth/authentication_flow_test.dart` |
| Accounts | `integration_test/accounts/accounts_display_test.dart` |
| Accounts | `integration_test/accounts/accounts_navigation_test.dart` |
| Movements | `integration_test/movements/movements_flow_test.dart` |
| Experience | `integration_test/experience/experience_flow_test.dart` |
| Navigation | `integration_test/navigation/navigation_flow_test.dart` |
| Notifications | `integration_test/notifications/notification_flow_test.dart` |
| API | `integration_test/api/real_backend_flow_test.dart` |

Helpers:

- `integration_test/support/api_http_server.dart`
- `integration_test/support/onboarding_test_support.dart`

Rule: before adding any new E2E, the nine existing tests are audited to
determine whether a real gap exists. New E2E scenarios are added only for
relevant gaps; the count of tests is never a goal by itself.

---

## 4. Final Regression

The final regression validates that no existing behavior is broken. It consists
of:

- `flutter analyze`;
- unit and widget tests (`flutter test`);
- integration tests (`flutter test integration_test/...`);
- API tests (`npm run test` in `api/`);
- Android debug build (`flutter build apk --debug`).

Exact test counts are not fixed as acceptance criteria here, because the audit in
later commits may adjust the suite.

---

## 5. Quality Gates

The intended gates are:

| Gate | Name | Description |
|---|---|---|
| Gate 1 | Static analysis | `flutter analyze` (and API lint) with no errors |
| Gate 2 | Unit/widget tests | `flutter test` green |
| Gate 3 | Integration/E2E tests | Deterministic E2E on a device/simulator green |
| Gate 4 | API validation | `npm run build`, `npm run lint`, `npm run test` green |
| Gate 5 | Android build | `flutter build apk --debug` succeeds |
| Gate 6 | Visual evidence generation | The six journey screenshots are produced |
| Gate 7 | Artifact publication | Test results, screenshots, and evidence uploaded as artifacts |

The concrete workflow implementation is defined in later commits. This document
fixes the gate model only.

---

## 6. Visual Evidence

The journey is frozen (already defined in PR22):

```text
Onboarding
    |
    v
Login
    |
    v
Home
    |
    v
Dynamic Experience
    |
    v
Accounts
    |
    v
Movements
```

The six screenshots are frozen:

```text
01_onboarding.png
02_login.png
03_home.png
04_dynamic_experience.png
05_accounts.png
06_movements.png
```

Dynamic Experience is the remotely configured experience composed on Home; it is
not a separate route, and its screenshot captures that section as rendered on
Home.

---

## 7. Screenshot Automation

Screenshot automation is defined as automated visual evidence derived from the
existing E2E flows.

- It must not duplicate functional assertions solely to take screenshots.
- It reuses the existing navigation and test helpers.
- The technical capture mechanism is decided during implementation; this
  specification does not fix a library, because the repository does not require
  one to define the behavior. The mechanism must run within `integration_test` so
  it can capture the real rendered application.

The screenshots do not exist until the automation produces them.

---

## 8. Artifacts

The expected artifact results are:

```text
test-results/     test and E2E outputs
screenshots/      the six journey screenshots
build/evidence/   build and evidence files
```

These are conceptual categories, not necessarily the final artifact bundle
paths. The concrete structure is decided during implementation. GitHub Actions
workflow artifacts are the retention mechanism, consistent with the PR22
strategy (`docs/delivery/visual-evidence-strategy.md`).

---

## 9. Acceptance Criteria

```text
AC-01  A PR23 specification exists (this document).
AC-02  The specification defines the scope and the exclusions.
AC-03  It inventories the nine existing E2E tests and the two helpers.
AC-04  It requires auditing existing E2E before creating new E2E.
AC-05  It defines the six screenshots and the visual journey.
AC-06  It defines the quality gates.
AC-07  It defines the expected evidence and artifact categories.
AC-08  It requires no product change (no new features, UI, or API changes).
AC-09  It does not claim that screenshot automation already exists.
AC-10  It does not claim that CI artifacts already exist.
```

---

## 10. Traceability

```text
REQ-012  At least one critical end-to-end flow
         -> Final regression and E2E audit.
REQ-024  Effective use of AI and development tools
         -> Automation of visual evidence and CI artifacts.
REQ-025  Accessible user interface
         -> The visual evidence documents the implemented UI; accessibility
            verification status is recorded separately in
            docs/delivery/accessibility-evidence.md.
BON-003  Automation for development, testing, deployment, or documentation
         -> Screenshot capture and artifact publication.
DEL-004  Deployment and operations documentation
         -> The evidence pipeline complements the documented delivery strategy.
```

`docs/product/requirements-traceability.md` is not modified in this commit; its
update belongs to later PR23 documentation work.

---

## 11. Scope Boundaries

In scope: final regression, quality gates, E2E gap audit and relevant additions,
screenshot automation, and CI artifact publication.

Out of scope: new product features, unnecessary UX changes, Crashlytics, new
external services, architecture changes, automatic deployment, and automatic
release.

---

## 12. Planned Sequence

The expected commit sequence is refined against the real repository structure as
work proceeds:

```text
C1  Specification (this document)
C2  Final regression / E2E gaps
C3  Screenshot capture
C4  CI quality gates
C5  CI artifacts
C6  Final verification / documentation
```

Commit boundaries are confirmed during implementation, not frozen here.
