# Final Delivery

## 1. Purpose

This area documents the final engineering delivery of the project: how the work
was developed (AI-assisted, SDD/TDD), how the application is delivered and
operated, the accessibility evidence that exists, and the visual evidence now
captured (PR25). It is documentation only; it does not introduce runtime or
pipeline changes.

## 2. PR22 Scope

PR22 — Final Delivery documents and prepares the final engineering evidence. It
covers AI-assisted development, deployment and operations, accessibility
evidence, and the screenshot/visual evidence strategy. It does not implement the
final quality gates, screenshot capture, or CI artifacts.

## 3. Delivery Pipeline (conceptual)

```text
Development
    |
    v
Pull Request
    |
    v
Automated validation        <- implemented (flutter-ci, api-ci)
    |
    v
Merge to main
    |
    v
Release build               <- documented strategy
    |
    v
Deployment / distribution   <- documented strategy
```

Automated validation currently runs on pull requests via
`.github/workflows/flutter-ci.yml` and `.github/workflows/api-ci.yml`. GitHub
Actions can publish build, test, and screenshot outputs as workflow artifacts,
but the current workflows do not upload artifacts. Screenshot capture is
implemented (PR25) as a local, reproducible artifact (`E2E-VIS-001`,
`screenshots/`); publishing screenshots as workflow artifacts remains a
documented strategy.

## 4. Implementation Status

The table separates what exists today from what is documented (strategy or
evidence) and what is planned for later work.

| Area | Currently implemented | Documented (no automation yet) | Future work |
|---|---|---|---|
| Validation | On pull request: `flutter analyze`, `flutter test`, `flutter build apk --debug` (flutter-ci); `npm run build`, `npm run lint`, `npm run test`, `npm run test:integration`, `npm run test:e2e` (api-ci, with a PostgreSQL 16 service) | — | — |
| Deployment / release | Build configuration only; no release or deployment pipeline | Release strategy: build Android/iOS, secrets handling, release, rollback, incident response | — |
| Accessibility | Semantic labels in onboarding, movements, and movement detail; tooltips in the app bar and login; widget assertion `ONB-W-006` | Evidence: verified vs pending (contrast, text scaling, touch targets) | TalkBack / VoiceOver validation |
| Visual evidence | Customer journey screenshots `01`–`06` captured by `E2E-VIS-001` (`integration_test/screenshots_capture_test.dart` + `test_driver/integration_test.dart`) and published in the README | Evidence: `screenshots/01`–`06` PNGs | Screenshot -> GitHub Actions artifact publication |

## 5. Documents

- [AI-assisted Development](ai-assisted-development.md) — AI usage,
  SDD -> TDD -> implementation -> validation, human review, impact, limits, and
  risks.
- [Deployment and Operations](deployment-and-operations.md) — build,
  configuration, secrets, CI/CD, release, rollback, incident response, and
  observability.
- [Accessibility Evidence](accessibility-evidence.md) — semantic labels, touch
  targets, contrast, text scaling, navigation, and onboarding accessibility
  (verified vs pending).
- [Visual Evidence Strategy](visual-evidence-strategy.md) — customer journey,
  screenshots `01`–`06`, and `E2E-VIS-001` (implemented in PR25 via
  `integration_test/screenshots_capture_test.dart`); the
  Integration Test -> Screenshot -> GitHub Actions -> Artifact flow remains the
  target.

## 6. Boundaries

Out of scope for PR22: screenshot capture tests, GitHub Actions screenshot
workflows, final regression suite, new E2E, golden tests, new features, UI
changes, API changes, architecture changes, and new quality gates. These are
outside the PR22 scope and remain future work.

Note: screenshot capture was implemented in PR25
(`docs/specs/pr25-visual-evidence.md`); the remaining items stay outside the
PR22 scope.
