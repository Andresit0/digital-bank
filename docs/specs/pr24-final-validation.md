# PR24 — Final Validation & Delivery

## Document Information

| Field | Value |
|---|---|
| Project | Digital Financial Platform — Flutter Technical Assessment |
| Document | PR24 Specification — Final Validation & Delivery |
| Status | Frozen (approved) |
| Depends on | PR18–PR23 (merged), the PR23 quality gate, and the delivery documentation (`docs/delivery/`) |
| Scope | Final validation, evidence, traceability, and delivery documentation |
| Platform | Flutter (Android/iOS) and NestJS API |

---

## 1. Purpose

Close the technical assessment by validating the delivered state and recording
its evidence. PR24 verifies functionality, tests, CI, requirements,
documentation, accessibility, observability, deployment, AI-assisted
development, and visual evidence, and it records known risks and limits.

PR24 introduces **no new product functionality**. This document is the
specification; it does not assert any result. Results are produced and recorded
in C2/C3.

---

## 2. Scope

In scope: final validation of the existing system, evidence recording,
documentation corrections (only where a real inconsistency exists), final
README status, traceability review, and delivery readiness.

Out of scope: new features, UX changes, architecture changes, Crashlytics, new
external services, automatic deployment, and automatic release.

---

## 3. Baseline

The validation starts from the merged history on `main`. The relevant
capabilities already exist and are the subject of validation, not of new work:

- onboarding, authentication, accounts, movements, dynamic experience,
  notifications, resilience, and observability;
- the Flutter unit/widget/integration suites and the API unit/integration/E2E
  suites;
- the PR23 API quality gate (PostgreSQL service + integration/E2E steps);
- the PR22 delivery documentation and the PR23 specification/audit.

This section describes what exists; it does not claim that any check passes.

---

## 4. Validation Areas

### 4.1 Flutter regression

```text
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Expected evidence: analyzer result, unit/widget test result, build artifact.

### 4.2 API validation

Run from `api/`, against a reachable PostgreSQL with `digital_bank_test`:

```text
npm ci
npm run build
npm run lint
npm run test
npm run test:integration
npm run test:e2e
```

Expected evidence: build/lint result and suite counts for unit, integration, and
E2E.

### 4.3 Flutter critical E2E

Validate the critical journeys defined by the project:

```text
flutter test integration_test/
```

Covering onboarding, authentication, navigation, accounts, movements,
experience, notifications, and the real-backend flow.

Expected evidence: E2E result per flow.

### 4.4 Requirements traceability

Verify that `docs/product/requirements-traceability.md` reflects the real state
for the critical requirements: authentication (REQ-001), accounts/movements
(REQ-002), personalization (REQ-003), external service (REQ-004), push
notifications (REQ-005), resilience (REQ-006–REQ-009), testing (REQ-010–REQ-012),
operations (REQ-013), and the derived/security/deliverable/bonus items.

Expected evidence: a requirement → architecture/ADR → implementation → tests →
documentation → evidence chain that is consistent with the artifacts.

### 4.5 Delivery documentation

Verify the PR22/PR23 delivery documentation is present and consistent:
final delivery, AI-assisted development, deployment and operations,
accessibility evidence, and visual evidence strategy.

Expected evidence: the documents exist and their statements match the system.

### 4.6 Accessibility

Verify the accessibility evidence state as documented in
`docs/delivery/accessibility-evidence.md`: verified, partially evidenced, and
not-yet-verified items. No item is promoted to verified without evidence.

### 4.7 Observability

Verify the provider-agnostic observability seam, the event taxonomy, the
sensitive-data policy, and the existing tests. No external provider is expected.

### 4.8 External service / FCM

Verify the Firebase Cloud Messaging integration (Android) and its safe CI
validation without credentials, as documented in PR19. Real FCM delivery is
device-dependent and validated separately.

### 4.9 Resilience / degraded states

Verify the bounded retry, in-memory read cache, connectivity abstraction, and
the explicit stale/degraded states for Accounts, Movements, and Experience
(PR20).

### 4.10 Deployment and operations

Verify the implemented deployment/operations facts: build configuration, CI
validation, secrets handling, observability, and incident response, as
documented in `docs/delivery/deployment-and-operations.md`. No automatic
release or deployment is expected.

### 4.11 AI-assisted development

Verify the AI-assisted development documentation
(`docs/delivery/ai-assisted-development.md`) is present and consistent with the
project workflow.

---

## 5. Result Criteria

```text
PASS          The check ran and completed successfully (no analyzer errors,
              all targeted tests passed, build succeeded).
FAIL          The check ran and produced an error or a failing test.
NOT VERIFIED  The check could not be executed due to a missing prerequisite
              (for example, no device/simulator or no reachable database), or the
              result was not captured. It is recorded explicitly and never
              counted as PASS.
```

Results are recorded factually. No percentages or numbers are invented.

---

## 6. Evidence to Record (C2/C3)

The validation audit (`docs/specs/pr24-final-validation-audit.md`) records, per
check:

- the exact command;
- the outcome (PASS / FAIL / NOT VERIFIED);
- counts where available (suites/tests);
- the environment (Flutter/Dart and Node versions; device/simulator; PostgreSQL);
- any prerequisite or limitation.

---

## 7. Traceability Method

For each critical requirement, the review follows:

```text
requirement
    |
    v
architecture / ADR
    |
    v
implementation
    |
    v
tests
    |
    v
documentation
    |
    v
evidence
```

Inconsistencies found are corrected only if they are real, in atomic commits
(C4).

---

## 8. Exit Criteria

```text
EC-01  All critical checks are PASS, or explicitly NOT VERIFIED with a recorded
       justification.
EC-02  No FAIL remains unexplained.
EC-03  No product functionality is changed in PR24.
EC-04  README reflects the final project status.
EC-05  Requirements traceability is consistent with the artifacts.
EC-06  The PR24 diff contains only validation/documentation changes.
EC-07  PR24 is delivered as a single independent PR against main.
```

---

## 9. Planned Sequence

```text
C1  Specification (this document)
C2  Run the validations
C3  Record the evidence (audit)
C4  Documentation corrections (only real inconsistencies)
C5  Final README status
C6  Traceability review
C7  Final Git validation and PR
```

Commit boundaries are confirmed as work proceeds.
