# Tasks: Accounts

Each implementation step follows RED to GREEN to REFACTOR.
The unit, widget, integration, and E2E scenarios are designed in this
specification before implementation begins.

1. SPEC
   - Redact and review the six specification files.
   - Confirm internal coherence before writing implementation code.

2. DOMAIN (commit: feat(accounts): implement account domain)
   - Implement `Account`, `AccountType`, `AccountsRepository`.
   - The domain depends on `shared/error` (`Result`, `AppError`).
   - RED to GREEN to REFACTOR.

3. INFRASTRUCTURE (commit: feat(accounts): implement account infrastructure)
   - Implement `AccountModel`, `AccountsRemoteDataSource`, `AccountsRepositoryImpl`.
   - Map infrastructure outcomes through `guard()` into `Result<List<Account>>`.
   - Write the integration test that exercises the real composition during this
     step, not after the feature is finished.
   - RED to GREEN to REFACTOR.

4. PRESENTATION (commit: feat(accounts): implement account presentation)
   - Implement `AccountsState`, `AccountsNotifier`, `AccountsScreen`, account widgets.
   - Register failures through `IObservability` at the notifier boundary.
   - Add a minimal Home with navigation to Accounts.
   - Widget tests with loading, loaded, empty, and error states.
   - RED to GREEN to REFACTOR.

5. INTEGRATION AND E2E (commit: test(accounts): complete integration and E2E coverage)
   - Consolidate integration coverage: successful load, empty, HTTP error,
     transport failure.
   - E2E: authenticated customer reaches accounts and sees balances.
   - This step consolidates coverage designed earlier, it is not the first time
     integration is addressed.

6. TRACEABILITY (commit: docs(accounts): document account traceability)
   - Update `docs/product/requirements-traceability.md`.
   - REQ-002: accounts and balances Implemented; movements Deferred.

## Definition of Done

- `flutter analyze` clean.
- `flutter test` green (unit + widget + integration-style).
- `flutter test integration_test/accounts/... -d <ios-simulator>` green.
- `git diff --check` clean.
- Specification scenarios (ACC / INT-ACC / WID-ACC / E2E-ACC) covered.
