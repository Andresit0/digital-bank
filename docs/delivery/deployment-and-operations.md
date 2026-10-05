# Deployment and Operations

## 1. Purpose

This document describes how the project is built, configured, validated, and
operated. It separates what is implemented today from the deployment and
operations strategy that is documented but not yet automated.

It relates to DEL-004 (deployment and operations documentation) and REQ-013
(monitoring and detection of production, operational, and UX issues).

The current reality is:

```text
Pull Request
    |
    v
flutter-ci / api-ci
    |
    v
Validation
```

There is no automatic release or deployment after validation. This document does
not claim one exists.

## 2. Implemented Today

### 2.1 Application build configuration

- Android: `namespace` and `applicationId` are `com.example.digital_bank`
  (`android/app/build.gradle.kts`); `minSdk` and `targetSdk` follow the Flutter
  defaults.
- iOS: bundle identifier `com.example.digitalBank` (`ios/Runner.xcodeproj`).
- API base URL is provided at build time with `--dart-define=API_BASE_URL=...`
  and read via `String.fromEnvironment` in `lib/core/config/app_config_provider.dart`.

### 2.2 Configuration and environment

- The backend is configured through environment variables, documented in
  `api/.env.example`: `STAGE`, `PORT`, database (`DB_HOST`, `DB_PORT`, `DB_NAME`,
  `DB_USERNAME`, `DB_PASSWORD`, `DB_SSL`), authentication (`JWT_SECRET`,
  `JWT_EXPIRES_IN`), seeding (`SEED_ON_START`), and Firebase
  (`FIREBASE_PROJECT_ID`, `GOOGLE_APPLICATION_CREDENTIALS`).
- `api/.env` is a local, untracked file. `.env` is ignored by `.gitignore`.

### 2.3 Secrets handling

- Secrets are kept out of the repository: `.gitignore` excludes `.env`,
  `**/service-account*.json`, and `**/*.p8`.
- The Flutter CI workflow rejects committed private credentials
  (`service-account*.json`, `*.p8`, `firebase-adminsdk*.json`) before building.
- Firebase server credentials are provided outside the repository through
  Application Default Credentials / `GOOGLE_APPLICATION_CREDENTIALS`.
- Client configuration that is not a server secret is tracked:
  `android/app/google-services.json` and the generated
  `lib/firebase_options.dart`. There is no iOS `GoogleService-Info.plist`.

### 2.4 CI validation on pull requests

Two GitHub Actions workflows validate pull requests to `main`:

| Workflow | Trigger | Steps |
|---|---|---|
| `.github/workflows/flutter-ci.yml` | `pull_request` → `main` | secret guard, Flutter setup, `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug` |
| `.github/workflows/api-ci.yml` | `pull_request` → `main` (paths `api/**`) | PostgreSQL 16 service (`pg_isready`), Node.js 24 setup, `npm ci`, `npm run build`, `npm run lint`, `npm run test`, `npm run test:integration`, `npm run test:e2e` |

Neither workflow runs on push to `main`, and neither has a release or deployment
job. Neither uploads artifacts.

### 2.5 Backend local deployment

The backend has a multi-stage `api/Dockerfile` and an `api/docker-compose.yml`
that runs PostgreSQL 16 and the API with a health check and
`restart: unless-stopped`. This is a local/development setup for running and
demonstrating the backend; it is not a production deployment.

### 2.6 Observability (implemented)

- A provider-agnostic observability seam (`IObservability`) with a default
  `NoopObservability`; by default no event leaves the application.
- A defined event taxonomy and severity model, and a sensitive-data policy
  (allowed metadata keys only; no credentials, tokens, account numbers, balances,
  PII, or payloads).
- An architecture test (`OBS-ARCH-001`) keeps features from importing concrete
  observability implementations.
- Full detail: `docs/architecture/adr/009-observability-and-monitoring.md`,
  `docs/architecture/pr14-production-observability.md`, and
  `docs/operations/README.md`.

### 2.7 Incident response (existing)

The operational signals are the reportable observability events. With a provider
adapter in place they would feed alerting and incident workflows. Until such an
adapter is integrated, the seam is a no-op and no signal is transmitted
externally (`docs/operations/README.md`).

## 3. Documented Strategy (Not Implemented)

The following describe the intended approach. They are not automated in this
repository.

### 3.1 Android and iOS builds

- Android: build an App Bundle (`flutter build appbundle --release`) with a
  release signing configuration.
- iOS: build an archive with the appropriate provisioning profiles and
  certificates.
- Today only a debug Android APK is built, in CI.

### 3.2 Per-environment configuration

- Distinct configurations for development, staging, and production supplied at
  build time through `--dart-define` (for example `API_BASE_URL`) and backend
  environment variables, rather than committed values.

### 3.3 Secrets management for CI

- Store signing keys, store credentials, and Firebase server credentials as
  GitHub Actions encrypted secrets, scoped to GitHub environments, and never in
  the repository or build outputs.

### 3.4 Release strategy

- Versioning and changelog, signed builds, and store distribution through the
  Google Play Console and App Store Connect tracks.

### 3.5 Rollback

- Pin releases to a known-good version and redeploy the previous build or store
  release when a regression is detected.

### 3.6 Deployment and distribution

- Publish client builds to the store tracks and host the backend with managed
  configuration and secrets.

### 3.7 CI/CD evolution

GitHub Actions supports separate build/test and deployment workflows, plus
environments, secrets, approvals, and concurrency controls. The intended
evolution is to add a build job that produces signed artifacts and a deployment
job gated by a protected environment. This is a documented strategy; none of it
is implemented here. In particular, artifacts are not currently produced or
uploaded by the workflows.

## 4. Explicitly Not Present

```text
Automatic release after CI        -> does not exist
Automatic deployment              -> does not exist
Workflow artifacts / screenshots  -> do not exist
Signed release builds in CI       -> do not exist
Production hosting configuration  -> does not exist
External observability provider   -> not integrated (seam is a no-op)
```

## 5. Delivery Pipeline: Implemented vs Target

```text
Implemented
Development -> Pull Request -> flutter-ci / api-ci (validation) -> Merge to main

Target (documented strategy)
Merge to main -> release build -> signed artifact -> deployment / distribution
```

## 6. Traceability

```text
DEL-004  Deployment and operations strategy documentation
         -> This document.
REQ-013  Monitor and detect production, operational, and UX issues
         -> Observability seam and taxonomy (Section 2.6); operational reading
            in docs/operations/README.md.
```

## 7. Boundaries

Out of scope for this document: implementing pipelines, workflows, signing,
store publishing, external providers, or infrastructure. Those are later work.
