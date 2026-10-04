# Tasks: Dynamic Experience

Each implementation step follows RED to GREEN to REFACTOR.
The unit, widget, integration, and E2E scenarios are designed in this
specification before implementation begins.

This task list is the map of the pull request commits (2 to 8).

1. SPEC (commit: docs(experience): define experience feature specification)
   - Redact and review the six specification files.
   - Confirm internal coherence before writing implementation code.

2. HOME EXTRACTION (commit: refactor(home): extract home screen into its own feature)
   - Move `HomeScreen` from `features/accounts/presentation/screens/` to
     `features/home/presentation/screens/`.
   - Update imports in `app/router/app_router.dart` and the two Accounts E2E
     tests.
   - Do NOT introduce Experience or ExperienceRenderer in this step.
   - Pure refactor: no functional Home behavior changes are allowed.
   - Definition of done: Home behavior unchanged, existing Accounts E2E tests
     remain green, and no Experience code is introduced.

3. DOMAIN (commit: feat(experience): implement experience domain)
   - Implement `ExperienceDefinition`, `ExperienceSection`, `PromotionSection`,
     `QuickActionSection`, `QuickActionType`, `ExperienceRepository`,
     `ExperienceError`.
   - `ExperienceState` is NOT part of the domain.
   - The domain depends on `shared/error` and does not depend on Flutter or
     go_router.
   - RED to GREEN to REFACTOR.

4. INFRASTRUCTURE (commit: feat(experience): implement experience infrastructure)
   - Implement `ExperienceDefinitionModel`, `ExperienceSectionModel`,
     `ExperienceRemoteDataSource`, `ExperienceRepositoryImpl`.
   - Endpoint `GET /experience/home`, isolated in the datasource.
   - Apply schema validation and map outcomes through `guard()` into
     `Result<..., AppError>`.
   - Do NOT introduce ExperienceRenderer in this step.
   - RED to GREEN to REFACTOR.

5. PRESENTATION AND RENDERER
   (commit: feat(experience): implement experience presentation and renderer)
   - Implement `ExperienceState`, `ExperienceNotifier`, `ExperienceRenderer`,
     `PromotionSection` widget, `QuickActionSection` widget, and
     `di/experience_providers.dart`.
   - Mount `ExperienceRenderer` in `features/home/presentation/screens/home_screen.dart`.
   - Experience expresses intents through `onAction(QuickActionType)`; Home
     resolves navigation. Experience must not import accounts, movements, or
     go_router.
   - RED to GREEN to REFACTOR.

6. INTEGRATION AND E2E (commit: test(experience): add integration and E2E coverage)
   - Integration-style: loaded, empty (INT-EXP-002), invalid schema, 5xx, and
     transport failure against the test server.
   - E2E: Login -> Home shows the dynamic experience; changing the server
     definition changes the rendered experience.
   - This step adds no production code and no documentation.

7. OBSERVABILITY (commit: refactor(experience): report production observability events)
   - Report `experience_load_failed` (warning) once from the notifier on
     failure, with error type and status code only.
   - No sensitive data in the event. Observability stays out of the datasource.
   - RED to GREEN to REFACTOR.

8. DOCUMENTATION
   (commit: docs(experience): accept ADR-005 and update traceability/README)
   - Add `docs/architecture/adr/005-dynamic-personalization.md` as Accepted.
   - Keep ADR-006 as Planned.
   - Update `docs/product/requirements-traceability.md` (REQ-003 Implemented;
     BON-002 secondary).
   - Update README (Home -> Dynamic Experience flow and the Experience E2E
     command).

## Definition of Done

- `flutter analyze` clean.
- `flutter test` green (unit + widget + integration-style).
- `flutter test integration_test/experience/... -d <ios-simulator>` green.
- `git diff --check` clean.
- Specification scenarios (EXP / INT-EXP / WID-EXP / E2E-EXP) covered.
