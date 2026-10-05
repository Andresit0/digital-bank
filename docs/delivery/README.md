# Final Delivery

## 1. Purpose

This area documents the final engineering delivery of the project: how the work
was developed (AI-assisted, SDD/TDD), how the application is delivered and
operated, the accessibility evidence that exists, and the strategy for
automating visual evidence. It is documentation only; it does not introduce
runtime or pipeline changes.

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
but the current workflows do not upload artifacts. Screenshot capture and
artifact publication are a documented strategy to be implemented in PR23.

## 4. Implementation Status

The table separates what exists today from what is documented (strategy or
evidence) and what is planned for later work.

| Area | Currently implemented | Documented (no automation yet) | Future implementation (PR23) |
|---|---|---|---|
| Validation | On pull request: `flutter analyze`, `flutter test`, `flutter build apk --debug` (flutter-ci); `npm run build`, `npm run lint`, `npm run test` (api-ci) | — | — |
| Deployment / release | Build configuration only; no release or deployment pipeline | Release strategy: build Android/iOS, secrets handling, release, rollback, incident response | — |
| Accessibility | Semantic labels in onboarding, movements, and movement detail; tooltips in the app bar and login; widget assertion `ONB-W-006` | Evidence: verified vs pending (contrast, text scaling, touch targets) | TalkBack / VoiceOver validation |
| Visual evidence | — | Strategy: customer journey and `E2E-VIS-001` (conceptual) | Screenshot capture -> GitHub Actions artifact |

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
  screenshots `01`–`06`, `E2E-VIS-001` (conceptual), and the future
  Integration Test -> Screenshot -> GitHub Actions -> Artifact flow.

## 6. Boundaries

Out of scope for PR22: screenshot capture tests, GitHub Actions screenshot
workflows, final regression suite, new E2E, golden tests, new features, UI
changes, API changes, architecture changes, and new quality gates. These belong
to PR23 and PR24.
