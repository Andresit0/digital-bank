# PR19 — External Service Integration (Firebase Cloud Messaging)

## Document Information

| Field | Value |
|---|---|
| Project | Digital Financial Platform — Flutter Technical Assessment |
| Document | PR19 Specification — External Service Integration (FCM) |
| Status | Frozen (approved) |
| Related ADR | ADR-003 (Networking, Error Handling and Resilience Boundaries), ADR-009 (Observability and Monitoring) |
| Related Requirements | REQ-004 (external service integration), REQ-005 (push notifications), SEC-003 (secrets and configuration separation), CON-002 (real service interaction) |
| Depends on | PR17 (NestJS backend foundation), PR18 (Flutter to NestJS API integration) |
| Scope | Cross-cutting (`core`), a new `notifications` feature, and the NestJS `notifications` module |
| Platform | Android |

---

## 1. Purpose

Integrate Firebase Cloud Messaging (FCM) as a real external service so a
financial notification can be delivered to an Android device and, when the user
taps it, can lead to an existing journey in the application (Movement detail
within Movements).

The goal is to demonstrate a real external-service integration, not a static
mock:

```text
Flutter (Android)
    |
    | FCM registration token
    v
NestJS (local)
    |
    | Firebase Admin SDK
    v
Firebase Cloud Messaging
    |
    | push
    v
Android device
    |
    | user taps
    v
Digital Bank -> Movements
```

FCM is the external third-party service. NestJS remains the project's own
backend. Flutter uses Firebase Messaging to initialize FCM, obtain and refresh
the registration token, and receive notifications. Notification delivery is
initiated server-side through the Firebase Admin SDK.

---

## 2. Frozen Decisions

| ID | Decision |
|---|---|
| D1 | Firebase Cloud Messaging is the external service used. |
| D2 | The initial demonstrable platform is Android. |
| D3 | The NestJS backend continues to run locally. No public domain, VPS, Cloud Run, AWS, Firebase Functions, or public tunnel is required. |
| D4 | Flow: Flutter/Android registers a device -> NestJS -> Firebase Admin SDK -> FCM -> Android. |
| D5 | Private credentials are never stored in Git. |
| D6 | The quality CI does not depend on secrets. |
| D7 | The notification payload contains no JWT, access tokens, secrets, or sensitive financial data. |
| D8 | Tapping the notification leads to a contextual journey (Movements / Movement detail). |
| D9 | `android/app/google-services.json` is versioned (client configuration with non-secret identifiers). |
| D10 | `POST /notifications/register` and `POST /notifications/send` are JWT-protected. |
| D11 | The device installation is persisted in PostgreSQL as `DeviceInstallation`. |
| D12 | iOS is out of scope for PR19. |
| D13 | NestJS uses `firebase-admin` with Application Default Credentials. |
| D14 | PR scope is `external-service`. |
| D15 | Branch is `feat/external-service`. |
| D16 | The payload is minimal and non-sensitive: `{ type, movementId }`. |

Dependency direction remains:

```text
shared  <-  core  <-  features
```

The `notifications` domain does not depend on Firebase. Only infrastructure does.

---

## 3. Scope Boundaries

In scope: FCM on Android, device registration, a NestJS sender using the
Firebase Admin SDK, persistence of the device installation, contextual
navigation on notification tap, documentation, and security.

Out of scope: iOS and APNs (`.p8`, Apple Developer Team ID, APNs key in
Firebase, Xcode Push Notifications / Background Modes, `GoogleService-Info.plist`,
`AppDelegate` APNs configuration, physical iPhone validation), Android < 13
notification-permission behavior as a dedicated validation scenario,
end-to-end encryption, backend deployment, personalization, and A/B testing.
Android < 13 is still supported; only its platform-specific permission behavior
is not a dedicated scenario.

### What iOS would have required (deferred)

For iOS, FCM requires a physical device for real validation, Push Notifications
and Remote Notifications capabilities, and an APNs authentication key configured
in Firebase. The APNs key is a private credential and is configured separately
in Firebase; it is never committed. Android was chosen as the initial platform
to keep the integration demonstrable without introducing Apple credentials.

---

## 4. Flow

```text
Android device
     |
     | FirebaseMessaging.getToken()
     v
Flutter (notifications feature)
     |
     | POST /notifications/register   (JWT)
     v
NestJS (notifications module)
     |
     | persists DeviceInstallation (userId + platform)
     v
PostgreSQL
```

Sending:

```text
Authorized client
     |
     | POST /notifications/send   (JWT, demonstration capability)
     v
NestJS
     |
     | firebase-admin
     v
Firebase Cloud Messaging
     |
     | notification/data message
     v
Android device
     |
     +-- foreground   (onMessage)
     +-- background   (onBackgroundMessage)
     +-- terminated   (getInitialMessage)
           |
           v
       Movements / Movement detail
```

---

## 5. Contracts

### 5.1 Flutter domain (`lib/features/notifications/`)

```text
domain/entities/notification_message.dart      # type, movementId (non-sensitive)
domain/repositories/notification_repository.dart
infrastructure/datasources/firebase_messaging_data_source.dart
infrastructure/repositories/firebase_notification_repository.dart
presentation/notifiers/notification_notifier.dart
di/notification_providers.dart
```

`NotificationRepository`:

```dart
abstract interface class NotificationRepository {
  Future<bool> requestPermission();
  Future<String?> getToken();
  Stream<String> refreshToken();
  Stream<NotificationMessage> onMessage();
  Stream<NotificationMessage> onOpened();
}
```

The domain exposes `NotificationMessage`; it never exposes a Firebase type. The
FCM registration token is treated as a technical delivery credential and is not
logged, returned by the API, or written to documentation or tests.

The infrastructure layer maps the Firebase foreground, background-open, and
terminated-launch mechanisms (`onMessage`, `onMessageOpenedApp`, and
`getInitialMessage`) into the domain notification contract. `onOpened()`
abstracts both `onMessageOpenedApp` (background) and `getInitialMessage`
(terminated launch), so the domain sees a single interaction intent.

### 5.2 NestJS (`api/src/notifications/`)

```text
notifications.module.ts
notifications.controller.ts
application/send-notification.use-case.ts
domain/notification-provider.interface.ts
infrastructure/firebase-notification.service.ts
```

Endpoints (both JWT-protected):

```text
POST /notifications/register   # associates a device installation with the user
POST /notifications/send       # demonstration/dev capability; not a public endpoint
```

Request body (`send`):

```json
{ "type": "movement", "movementId": "..." }
```

`/notifications/send` is a demonstration capability. No public endpoint may
allow arbitrary clients to send notifications.

### 5.3 Persistence

```text
DeviceInstallation
------------------
id
userId
firebaseInstallationId
fcmRegistrationToken
platform
lastSeenAt
createdAt
updatedAt
```

In PR19 `platform = android`. The registration token/FID are never logged,
committed, documented, returned in unnecessary responses, or used as real
fixtures in tests (tests use synthetic values such as
`fake-fcm-registration-token`).

---

## 6. Security

Private credentials never enter Git:

```text
# Firebase / server private credentials
**/service-account*.json
**/*.p8

# Local environment
.env
.env.*
!.env.example
```

`android/app/google-services.json` is versioned because it contains non-secret
client identifiers for the Android app. The NestJS service account remains
strictly server-side and is provided through the environment:

```text
GOOGLE_APPLICATION_CREDENTIALS=/path/outside/the/repository/service-account.json
```

Nothing sensitive is logged. Allowed diagnostics:

```text
FCM token registered
Notification permission granted
Notification received
Notification interaction received
tokenPresent: true
```

Never logged: FCM token, FID, JWT, access token, private key, service account,
or any financial data.

---

## 7. Scenarios

Automatic (deterministic, no secrets, no Firebase):

```text
NOT-001  Notification permission can be requested
NOT-002  FCM token can be obtained
NOT-003  FCM token refresh is propagated
NOT-004  Incoming notification is converted to a domain notification
NOT-005  Notification interaction exposes a navigation intent
NOT-006  Notification failures do not crash the application

FCM-001  Firebase initializes on Android
FCM-002  Android obtains the FCM registration token
FCM-003  Token refresh updates the installation
FCM-004  Android 13+ runtime notification permission is requested
```

Manual (physical Android device; no secrets committed):

```text
FCM-005  Foreground message (onMessage)
FCM-006  Background message (onBackgroundMessage)
FCM-007  Tapping an FCM notification opens a previously terminated app and
         exposes its initial message (getInitialMessage)
FCM-008  Tapping the notification opens the application
FCM-009  movement payload navigates to Movements
FCM-010  NestJS -> Firebase Admin -> FCM
FCM-011  FCM -> Android device
```

An Android emulator with Google Play can also be used; a physical device gives
the most direct validation of the real flow. Automated tests remain
deterministic and use fakes (`FakeNotificationRepository`,
`FakeFirebaseMessagingDataSource`); they never contact Firebase.

---

## 8. Acceptance Criteria

```text
AC-01 FCM is integrated as a real external service on Android.
AC-02 The Flutter app obtains and registers the FCM token.
AC-03 The device installation is persisted and associated with the user.
AC-04 NestJS sends a notification through the Firebase Admin SDK.
AC-05 The notification payload is minimal and non-sensitive (D16).
AC-06 No private credential is committed to Git.
AC-07 The quality CI passes without Firebase secrets.
AC-08 Tapping the notification leads to Movements / Movement detail.
AC-09 Automated tests are deterministic and do not depend on Firebase.
AC-10 flutter analyze returns 0 issues and flutter test passes.
```

---

## 9. Traceability (Target)

This section states the objective of PR19. The traceability matrix is updated
with evidence only after implementation and validation (Commit 6).

```text
REQ-004  Integrate at least one external service
         -> FCM is integrated as a real external service.

REQ-005  Push notifications
         -> A financial notification is delivered to Android and can lead to
            Movements.

SEC-003  Secrets and configuration separation
         -> Private server credentials (Firebase service account) stay outside
            Git; Android client configuration with non-secret identifiers is
            versioned.

CON-002  Real service interaction
         -> Real external-service delivery (FCM), beyond simulated data.
```

---

## 10. Out of Scope

- iOS and APNs, `.p8`, Apple Developer Team ID, APNs key in Firebase, Xcode
  Push Notifications / Background Modes, `GoogleService-Info.plist`, APNs
  `AppDelegate` configuration, physical iPhone validation.
- Android configuration beyond FCM (no additional Firebase products).
- End-to-end encryption of notification content.
- Public deployment of the backend, Firebase Functions, or a public tunnel.
- Personalization engine, feature flags, A/B testing.

---

## 11. Definition of Done

```text
Architecture
- FCM integrated as an external service; the notifications domain is Firebase-free.
- DeviceInstallation persisted and associated with the user.
- No default account or business rule is invented for delivery.

Security
- No private credential in Git; .gitignore updated.
- No sensitive value logged; only non-sensitive diagnostics.
- Payload contains no JWT, tokens, secrets, or financial data.

Delivery
- Android obtains the FCM token and handles refresh.
- NestJS sends through the Firebase Admin SDK.
- Android 13+ requests the notification permission at runtime. The effective
  `POST_NOTIFICATIONS` declaration is validated after the manifest merger; a
  duplicate entry is not added manually if the FCM SDK already provides it.
- Tapping the notification opens Movements / Movement detail.

Tests
- Notification contract tests (NOT-001..006).
- Firebase behavior tests (FCM-001..004) with fakes.
- Deterministic E2E for payload -> navigation.
- Quality CI passes without secrets.

Validation
- flutter analyze clean; flutter test green.
- Manual validation on an Android device (foreground/background/terminated).
- README and traceability updated (Commit 6).
```

---

## 12. Commit Plan

```text
1 docs(external-service): define FCM integration contract
2 test(notifications): define notification contracts
3 feat(notifications): add Firebase messaging client
4 feat(api): add Firebase notification delivery
5 feat(notifications): connect notification navigation
6 ci(firebase): validate external service integration safely
```

Commits represent logical units of change. Each step follows SDD then TDD, and
stops for review before the next step.
