# PR23 — Final Regression & E2E Gap Audit (C2)

## Document Information

| Field | Value |
|---|---|
| Project | Digital Financial Platform — Flutter Technical Assessment |
| Document | PR23 C2 — Final Regression & E2E Gap Audit |
| Status | Result recorded |
| Related | `docs/specs/pr23-quality.md` (frozen PR23-C1 specification) |
| Scope | Audit result and the resulting CI change; no product change |

---

## 1. Purpose

This document records the factual result of the PR23-C2 audit: the state of the
existing test suites, the gap found in CI, the local validation performed, and
the decision taken. It does not replace the frozen specification; it records the
outcome of executing it.

---

## 2. Initial State (measured)

Flutter regression:

```text
flutter analyze                       No issues found (0)
flutter test                          398 passed
flutter test integration_test/        18 passed
flutter build apk --debug             OK (app-debug.apk)
```

API suites (`api/`):

```text
npm run test              6 suites / 17 tests
npm run test:integration  5 suites / 13 tests
npm run test:e2e          2 suites / 10 tests
```

Integration/E2E suites present:

```text
test/integration: accounts, experience, movements, notifications, seed (5)
test/e2e:         auth, notifications (2)
```

The existing Flutter E2E coverage already spans Onboarding, Auth, Navigation,
Accounts, Movements, Experience, Notifications, and the real API (9 tests).

---

## 3. Finding

- `api-ci.yml` ran `npm test` only. Because `npm test` uses the `package.json`
  Jest configuration with `rootDir: src` and `testRegex: ".*\.spec\.ts$"`, it
  executes only `src/**/*.spec.ts`.
- The 7 additional suites under `test/integration/` and `test/e2e/` were
  therefore **not part of CI**, even though they exist and pass locally.
- No functional E2E gap was found in the Flutter journey: the nine existing E2E
  tests already cover the critical domains.

---

## 4. Validation

Local validation against a real PostgreSQL 16 from `docker-compose`
(`api-postgres-1`, healthy, port `5432`):

```text
npm run test:integration   5/5 suites, 13/13 tests passed
npm run test:e2e           2/2 suites, 10/10 tests passed
```

- No changes to the existing suites were required.
- No unexpected environment variables appeared; the suites set
  `STAGE=dev`, `DB_NAME=digital_bank_test`, and `SEED_ON_START=true` through
  `test/support/create-test-app.ts`.
- The required external dependency is a reachable PostgreSQL with the
  `digital_bank_test` database, plus `JWT_SECRET` (no default in code).

---

## 5. Decision

- Incorporate the API integration and E2E suites into the API workflow,
  reproducing the validated environment with a `postgres:16-alpine` service
  container, a `pg_isready` health check, and CI-only dummy credentials.
- Do **not** add new functional E2E.
- `E2E-VIS-001` (visual evidence journey) remains deferred to C3.

Resulting workflow change: `.github/workflows/api-ci.yml` (service, env, and the
`test:integration` and `test:e2e` steps). No artifacts are added in C2.

---

## 6. Evidence

```text
# Flutter regression
flutter analyze
flutter test
flutter test integration_test/
flutter build apk --debug

# API suites (local, against docker-compose PostgreSQL)
cd api
npm run test
npm run test:integration
npm run test:e2e
```

---

## 7. Out of Scope

New functional E2E, screenshots, screenshot automation, CI artifacts, workflow
restructuring for quality gates, product changes, and deployment are not part of
this audit; they belong to later PR23 commits (C3–C5).
