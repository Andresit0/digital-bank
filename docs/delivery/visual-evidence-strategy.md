# Visual Evidence Strategy

## 1. Objective

Define how visual evidence of the main customer journey is produced, automated,
and retained as final delivery evidence. The objective is to:

- demonstrate the main functional journey in a single visual sequence;
- complement, not replace, the existing functional end-to-end tests;
- provide evidence attached to the delivery.

The screenshot capture is implemented (PR25). Publishing the screenshots as
GitHub Actions artifacts remains the target retention mechanism.

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

## 3. Screenshots

| # | File | Journey step | Notes |
|---|---|---|---|
| 01 | `01_onboarding.png` | Onboarding | First-run onboarding page |
| 02 | `02_login.png` | Login | Authentication screen |
| 03 | `03_home.png` | Home | Authenticated home |
| 04 | `04_dynamic_experience.png` | Dynamic Experience | Dynamic experience section composed on Home |
| 05 | `05_accounts.png` | Accounts | Account summary |
| 06 | `06_movements.png` | Movements | Movement history |

The six screenshots are committed under `screenshots/` and published in the
README.

## 4. E2E-VIS-001

`E2E-VIS-001` is the end-to-end test that walks the journey above and captures
one screenshot per step. It is implemented in
`integration_test/screenshots_capture_test.dart`.

- **Capture mechanism:** `IntegrationTestWidgetsFlutterBinding.takeScreenshot`
  after pumping a settled frame, so the captured image reflects the real
  rendered application.
- **Materialization:** `test_driver/integration_test.dart` implements the
  `integration_test_driver_extended` `onScreenshot` callback and writes each PNG
  under `screenshots/`.
- **Data source:** the controlled local HTTP server
  (`integration_test/support/api_http_server.dart`) serves fixed accounts,
  movements, and a dynamic experience; onboarding is seeded through
  `integration_test/support/onboarding_test_support.dart`. No network or real
  backend is required.
- **Additivity:** the capture reuses the navigation and helpers of the existing
  E2E flows, without duplicating the functional assertions that those tests
  already make, and without replacing them.

## 5. Capture Pipeline

```text
Integration Test (E2E-VIS-001)
      |
      v
Screenshot capture (takeScreenshot)
      |
      v
Driver (onScreenshot)
      |
      v
screenshots/ (committed evidence)
      |
      v
README gallery
```

GitHub Actions artifacts are the intended retention mechanism for screenshots
and test outputs. The capture and the committed screenshots are implemented; the
current workflows do not upload artifacts.

## 6. Responsibility Boundary

| Phase | Responsibility for visual evidence |
|---|---|
| Final Delivery (PR22) | Define and document the strategy |
| Visual evidence capture (PR25) | Implement `E2E-VIS-001`, the driver, the six screenshots, and the README gallery |
| CI artifact publication | Future work |

## 7. Current State

```text
Screenshots                          -> captured (screenshots/01–06)
E2E-VIS-001 test                     -> implemented
Screenshot capture code              -> implemented (test_driver/integration_test.dart)
GitHub Actions screenshot workflow   -> not implemented
Workflow artifacts                   -> not uploaded
```

## 8. Reproducibility

The screenshots are regenerated on a booted iOS simulator or Android device
with:

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshots_capture_test.dart \
  -d <device-id>
```

Regeneration criteria:

```text
- the test passes;
- exactly the six PNG files are produced;
- the file names are exact;
- each file has a reasonable, non-empty size;
- no additional files are generated;
- the images correspond to the journey steps in order.
```

## 9. Traceability

```text
BON-003  Automation for development, testing, deployment, or documentation
         -> Implemented: screenshot capture and driver automation (PR25);
            artifact publication remains future work.
REQ-024  Effective use of AI and development tools
         -> Automated visual evidence implemented (PR25).
REQ-012  Critical end-to-end flow
         -> Already covered by the existing functional E2E tests; visual evidence
            is additive and does not replace them.
```

## 10. Boundaries

This document does not change the application, add product behavior, or modify
the CI workflows. It records the implemented capture and defers artifact
publication to future work.
