# Tasks: Movements

Each implementation step follows RED to GREEN to REFACTOR.
The unit, widget, integration-style, and E2E scenarios are designed in this
specification before implementation begins.

1. SPEC
   - Redact and review the six specification files.
   - Confirm internal coherence before writing implementation code.

2. DOMAIN (commit: feat(movements): implement movements domain)
   - Implement `Movement`, `MovementType`, `MovementsRepository`.
   - `fetchMovements({required String accountId})` returns `Result<List<Movement>>`.
   - The domain depends on `shared/error` (`Result`, `AppError`) and does not
     depend on `go_router`.
   - RED to GREEN to REFACTOR.

3. INFRASTRUCTURE (commit: feat(movements): implement movements infrastructure)
   - Implement `MovementModel`, `MovementsRemoteDataSource`, `MovementsRepositoryImpl`.
   - Map infrastructure outcomes through `guard()` into `Result<List<Movement>>`.
   - Endpoint `GET /accounts/{accountId}/movements`, isolated in the datasource.
   - RED to GREEN to REFACTOR.

4. PRESENTATION (commit: feat(movements): implement movements presentation)
   - Implement `MovementsState`, `MovementsNotifier`, `MovementsScreen`,
     `MovementDetailScreen`, movement widgets.
   - `MovementsNotifier.load` requires `accountId` (provided by the caller); it
     never infers a selected account.
   - Read `accountId` from `GoRouterState.uri.queryParameters` at the screen
     boundary and pass it to the notifier.
   - Detail route `/movements/:id` reuses the loaded `Movement`; no HTTP request.
   - Replace the `AppRoute.transactions` placeholder with `AppRoute.movements`.
   - Enable navigation from `AccountCard` to `/movements?accountId=<id>`
     (navigation only; no changes to Account entity, repository, datasource, or
     Accounts state).
   - RED to GREEN to REFACTOR.

5. INTEGRATION AND E2E (commit: test(movements): complete integration and E2E coverage)
   - Integration-style: load, empty, HTTP error, transport failure, wiring.
   - E2E: login -> home -> accounts -> movements; movements -> detail; detail -> back keeps the list.

6. OBSERVABILITY (commit: refactor(movements): report production observability events)
   - Report `movements_load_failed` (warning) once from the notifier on failure,
     with `errorType` and `statusCode` only for `ApiError`.
   - No sensitive data in the event.

7. TRACEABILITY AND DOCS (commit: docs(movements): update traceability, taxonomy and README)
   - Update `docs/product/requirements-traceability.md` (REQ-002, REQ-009).
   - Add `movements_load_failed` to `docs/architecture/adr/009-observability-and-monitoring.md`
     and `docs/operations/README.md` (do not modify the PR14 specification).
   - Update `README.md` Project Status and the implemented customer journey.

## Definition of Done

- `flutter analyze` clean.
- `flutter test` green (unit + widget + integration-style).
- `flutter test integration_test/movements/... -d <ios-simulator>` green.
- `git diff --check` clean.
- Specification scenarios (UNIT-MOV / MOV-REPO / WID-MOV / INT-MOV / E2E-MOV) covered.
- `accountId` originates only from the navigation context and reaches
  `fetchMovements({required String accountId})`; the domain does not depend on
  `go_router`.
- Ownership is enforced by the authenticated backend session; the client does
  not treat `accountId` as proof of ownership.
- There is a single movements endpoint and no independent detail state.
