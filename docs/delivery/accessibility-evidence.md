# Accessibility Evidence

## 1. Purpose

This document records the accessibility evidence that exists in the project and
what remains to be verified. It describes what is implemented and test-backed
today, not what is intended. It relates to REQ-025 (accessible user interface)
and to the accessibility criterion EC-003.

It does not assert that any screen is accessible merely because it uses standard
widgets. Each claim below is tied to code, a test, or is explicitly marked as not
yet verified.

## 2. Status Model

```text
Verified evidence      backed by a passing automated test
        |
        v
Partially evidenced    implemented in code or specified, but not backed by an
        |              accessibility test
        v
Not yet verified       no evidence
```

## 3. Evidence Inventory

| Area | Status | Evidence |
|---|---|---|
| Semantic labels (onboarding controls) | Verified | `ONB-W-006` asserts `Skip onboarding` and `Next onboarding step` |
| Semantic labels (movements) | Partially evidenced | `Semantics` in movement tile, list, and detail (no accessibility test) |
| Tooltips / accessible descriptions | Partially evidenced | `tooltip` on the app bar profile action and the login password toggle |
| Onboarding accessibility (ONB-012) | Partially evidenced | `ONB-W-006` covers labels; text scaling, contrast, and touch targets are not verified |
| Touch targets | Not yet verified | No `meetsGuideline(androidTapTargetGuideline/iOSTapTargetGuideline)` test or audit |
| Contrast | Not yet verified | No `textContrastGuideline` test or audit |
| Text scaling | Not yet verified | No test exercising `textScaler` / large font sizes |
| TalkBack (Android) | Not yet verified | No evidence |
| VoiceOver (iOS) | Not yet verified | No evidence |
| Accessible navigation | Partially evidenced | Guarded routing and some semantics exist; no screen-reader traversal verification |

## 4. Verified Evidence

The only accessibility assertion backed by an automated test is the onboarding
control labels:

- `test/features/onboarding/presentation/screens/onboarding_screen_test.dart`,
  test `ONB-W-006`, enables semantics (`tester.ensureSemantics()`) and asserts
  `find.bySemanticsLabel('Skip onboarding')` and
  `find.bySemanticsLabel('Next onboarding step')`.

This verifies labels only. It does not verify contrast, text scaling, touch
targets, or screen-reader behavior.

## 5. Partially Evidenced

These affordances are present in code but are not covered by an accessibility
test, so they are not counted as verified:

- **Onboarding controls** (`lib/features/onboarding/presentation/screens/onboarding_screen.dart`):
  `Semantics` with `label`, `button: true`, `onTap`, and `excludeSemantics: true`
  on the Skip and primary buttons; decorative icon containers excluded from
  semantics; primary button `minimumSize: Size.fromHeight(56)`.
- **Movement tile** (`lib/features/movements/presentation/widgets/movement_tile.dart`):
  a composed `Semantics` label (description, credit/debit, amount, date, and a
  "View movement details" action) with `button: true`.
- **Movements list** (`lib/features/movements/presentation/screens/movements_screen.dart`):
  a section heading with `Semantics(headingLevel: 2)`, a header container, and a
  labeled `Retry` action.
- **Movement detail** (`lib/features/movements/presentation/screens/movement_detail_screen.dart`):
  a container `Semantics` label ("Credit/Debit movement", description, amount).
- **Tooltips** (`lib/shared/presentation/widgets/bank_app_bar.dart`,
  `lib/features/auth/presentation/screens/login_screen.dart`): the profile action
  has `tooltip: 'Profile'`, and the password visibility toggle has
  `tooltip: 'Show password'` / `'Hide password'`.
- **ONB-012 (spec)** (`docs/architecture/pr21-onboarding.md`): states that
  onboarding controls expose semantic labels, respect text scaling, maintain
  accessible contrast, and use appropriate touch targets. Only the semantic-label
  part has test evidence (`ONB-W-006`); the remaining claims are not verified.

Note: the accounts and home screens have no explicit `Semantics` widgets. They
rely on the semantics of standard Material widgets, which is not the same as
verified accessibility.

## 6. Not Yet Verified

The following have no supporting evidence and must not be described as verified:

- **Touch targets.** No test uses `meetsGuideline` with
  `androidTapTargetGuideline` or `iOSTapTargetGuideline`, and no manual audit was
  performed. The onboarding primary button is sized at 56; other targets rely on
  Material defaults.
- **Contrast.** No `textContrastGuideline` test and no contrast audit.
- **Text scaling.** No test renders the UI at increased text scale, and the
  layouts use several fixed font sizes.
- **TalkBack.** No validation on Android.
- **VoiceOver.** No validation on iOS.
- **Accessible navigation.** No screen-reader traversal of the journey
  (Onboarding -> Login -> Home -> Accounts -> Movements) has been recorded.

## 7. Tooling for the Remaining Verification

The following are the intended mechanisms for closing the gaps above. They are
not yet applied:

- Flutter's accessibility guidelines through `meetsGuideline`: tap target
  (Android/iOS), labeled tap target, and text contrast.
- Accessibility Scanner / Accessibility Inspector for platform-level checks.
- TalkBack and VoiceOver for screen-reader validation.
- Increasing text scale for layout and truncation checks.

## 8. Traceability

```text
REQ-025  Provide an accessible user interface
         -> Verified: onboarding semantic labels (ONB-W-006).
         -> Partially evidenced: movements semantics, tooltips, ONB-012 scope.
         -> Not yet verified: touch targets, contrast, text scaling,
            TalkBack, VoiceOver, accessible navigation.
```

REQ-025 therefore remains in progress; this document records evidence and does
not mark it as Verified.

## 9. Boundaries

This document does not modify UI code, add accessibility tests, or run platform
screen-reader validation. Those are later work. It only records the current
evidence state.
