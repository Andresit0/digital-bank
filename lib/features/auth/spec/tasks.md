# Tasks: Authentication

Each implementation step follows RED to GREEN to REFACTOR.

1. SPEC
   - Redact and review the six specification files.
   - Confirm internal coherence before writing implementation code.

2. TDD RED
   - Write contract and behavior tests first, derived from the scenarios.
   - Tests fail because the implementation does not exist yet.

3. DOMAIN
   - Implement `AuthSession`, `AuthRepository`, `AuthState`, `AuthError`.
   - RED to GREEN to REFACTOR.

4. INFRASTRUCTURE
   - Implement `AuthResponseModel`.
   - Implement `AuthRemoteDataSource` using `HttpClient`.
   - Implement `AuthRepositoryImpl`.
   - Map HTTP and transport outcomes to `AuthError` in `AuthRepositoryImpl`.
   - Keep transport-specific types out of presentation and domain.
   - RED to GREEN to REFACTOR.

5. CORE CONFIG
   - Introduce minimal `AppConfig` with `apiBaseUrl` and `appConfigProvider`.
   - Ensure `dioProvider` composes the base URL from configuration.
   - RED to GREEN to REFACTOR.

6. PRESENTATION
   - Implement `AuthNotifier`, `authProvider`, and `LoginScreen`.
   - RED to GREEN to REFACTOR.

7. INTEGRATION
   - Wire dependency composition for authentication.
   - Implement the minimal routing guard and the `refreshListenable` adapter.
   - The router and guard are implemented only after `AuthNotifier` is functional.
   - RED to GREEN to REFACTOR.

8. VERIFICATION
   - `dart format .`
   - `flutter analyze`
   - `flutter test`
   - `git diff --check`

9. TRACEABILITY
   - Update `docs/product/requirements-traceability.md` to reflect the real state
     of REQ-001 and the related security items.
