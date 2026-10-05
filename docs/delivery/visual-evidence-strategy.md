# Visual Evidence Strategy

## 1. Objective

Define how visual evidence of the main customer journey will be produced,
automated, and retained as final delivery evidence. The objective is to:

- demonstrate the main functional journey in a single visual sequence;
- complement, not replace, the existing functional end-to-end tests;
- provide evidence attached to the delivery (workflow artifacts).

This document defines the strategy only. It does not capture any screenshot and
does not implement any automation.

## 2. Customer Journey

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

Note: "Dynamic Experience" is the remotely configured, schema-controlled
experience composed on Home, not a separate route. Its screenshot captures that
section as rendered on the Home screen.

## 3. Planned Screenshots

| # | File | Journey step | Notes |
|---|---|---|---|
| 01 | `01_onboarding.png` | Onboarding | First-run onboarding page |
| 02 | `02_login.png` | Login | Authentication screen |
| 03 | `03_home.png` | Home | Authenticated home |
| 04 | `04_dynamic_experience.png` | Dynamic Experience | Dynamic experience section composed on Home |
| 05 | `05_accounts.png` | Accounts | Account summary |
| 06 | `06_movements.png` | Movements | Movement history |

## 4. E2E-VIS-001 (Planned, Conceptual)

`E2E-VIS-001` is the conceptual test that will walk the journey above and capture
one screenshot per step. Its status is **Planned / conceptual**; it is not
implemented in PR22.

When implemented (future work), it should:

- reuse the existing navigation and test helpers rather than introduce a parallel
  harness, for example `integration_test/support/onboarding_test_support.dart`
  (onboarding completion seeding) and `integration_test/support/api_http_server.dart`
  (controlled local server);
- drive the real journey used by the existing E2E tests
  (`integration_test/onboarding/`, `auth/`, `accounts/`, `movements/`,
  `experience/`);
- capture screenshots additively, without duplicating the functional assertions
  that the existing E2E tests already make.

The screenshots themselves do not exist yet; none should be presented as captured
until the automation produces them.

## 5. Future Pipeline

```text
Integration Test
      |
      v
Screenshot capture
      |
      v
GitHub Actions
      |
      v
Artifact
      |
      v
Final evidence
```

GitHub Actions artifacts are the intended retention mechanism for screenshots and
test outputs. This pipeline is a documented strategy; none of it is implemented,
and the current workflows do not upload artifacts.

## 6. Responsibility Boundary

| Phase | Responsibility for visual evidence |
|---|---|
| Final Delivery (PR22) | Define and document this strategy |
| Future work | Implement screenshot capture, automation, and artifacts |
| Final validation | Consolidate the available evidence and traceability |

## 7. What Does Not Exist Today

```text
Screenshots                          -> not captured
E2E-VIS-001 test                     -> not implemented (conceptual)
Screenshot capture code              -> does not exist
GitHub Actions screenshot workflow   -> does not exist
Workflow artifacts                   -> not uploaded
```

## 8. Traceability

```text
BON-003  Automation for development, testing, deployment, or documentation
         -> Planned: screenshot capture and artifact publication (future work).
REQ-024  Effective use of AI and development tools
         -> Automated visual evidence is part of the intended automation, not yet
            implemented.
REQ-012  Critical end-to-end flow
         -> Already covered by the existing functional E2E tests; visual evidence
            is additive and does not replace them.
```

## 9. Boundaries

This document does not add tests, capture screenshots, modify workflows, or
upload artifacts. It records the intended approach and defers the implementation
to future work.
