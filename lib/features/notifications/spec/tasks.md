# Tasks: Notifications (Firebase Cloud Messaging)

Each implementation step follows RED to GREEN to REFACTOR.
The scenarios are designed in this specification before implementation begins.

This task list maps to the six PR19 commits.

1. SPEC (commit: docs(external-service): define FCM integration contract)
   - Redact and review `docs/architecture/pr19-external-service-integration.md`.
   - Update requirements traceability for REQ-004 as a target.
   - Do NOT touch code, README, pubspec, android, ios, api, or CI.

2. CONTRACTS AND TESTS (commit: test(notifications): define notification contracts)
   - Add the six specification files under `lib/features/notifications/spec/`.
   - Define the domain contract and the RED tests with fakes.
   - No Firebase dependency yet; tests are deterministic.

3. FLUTTER CLIENT
   (commit: feat(notifications): add Firebase messaging client)
   - Add `firebase_core` and `firebase_messaging`.
   - Add `android/app/google-services.json` (versioned) and the google-services
     Gradle plugin.
   - Implement `NotificationMessage`, `NotificationIntent`, `NotificationType`,
     `NotificationRepository`, `NotificationError`, the Firebase datasource,
     the repository implementation, notifier, and DI.
   - Android 13+: validar la declaracion efectiva de `POST_NOTIFICATIONS`
     despues del manifest merger y solicitar el permiso en runtime cuando
     corresponda. No anadir una declaracion duplicada si el SDK ya la provee.
   - The domain must not import Firebase.
   - RED to GREEN to REFACTOR.

4. BACKEND DELIVERY
   (commit: feat(api): add Firebase notification delivery)
   - Add `firebase-admin` to `api/`.
   - Implement `DeviceInstallation` entity, `notifications` module,
     `POST /notifications/register` and `POST /notifications/send` (JWT
     protected), and the Firebase Admin sender.
   - `.env.example` documents `GOOGLE_APPLICATION_CREDENTIALS` without values.
   - The service account stays outside the repository.
   - RED to GREEN to REFACTOR.

5. NAVIGATION (commit: feat(notifications): connect notification navigation)
   - Map a `movement` intent to `/movements` (and Movement detail).
   - The payload contains no sensitive data.
   - RED to GREEN to REFACTOR.

6. CI AND DOCUMENTATION
   (commit: ci(firebase): validate external service integration safely)
   - Quality CI runs `flutter analyze`, `flutter test`, `flutter build apk`
     without Firebase secrets.
   - Update `.gitignore` for server credentials.
   - Update README (Project Status, Engineering Approach) and traceability
     with PR19 evidence.

## Definition of Done

- `flutter analyze` clean.
- `flutter test` green (unit + integration-style).
- Deterministic notification E2E green.
- Manual validation on an Android device for FCM-005..011.
- `git diff --check` clean.
- Scenarios (NOT / FCM / E2E-NOT) covered.
