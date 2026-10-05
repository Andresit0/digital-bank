# Tests: Notifications (Firebase Cloud Messaging)

Tests derive from the specification scenarios, not from the implementation.
Unit, integration, and E2E scenarios are defined before implementation. No test
contacts Firebase or uses a real token.

## Requirement to Scenario to Test

| Requirement | Scenario | Test Level |
|---|---|---|
| REQ-005 | Notification permission requested | unit, integration |
| REQ-005 | FCM token obtained | unit, integration |
| REQ-005 | Token refresh propagated | unit, integration |
| REQ-005 | Incoming notification to domain message | unit |
| REQ-004 | Notification interaction exposes navigation intent | unit, integration, E2E |
| REQ-005 | Notification failures do not crash | unit, widget |

## Unit Scenarios

| ID | Scenario |
|---|---|
| NOT-001 | Notification permission can be requested |
| NOT-002 | FCM token can be obtained |
| NOT-003 | FCM token refresh is propagated |
| NOT-004 | Incoming notification is converted to a domain notification |
| NOT-005 | Notification interaction exposes a navigation intent |
| NOT-006 | Notification failures do not crash the application |

## Firebase Behavior Scenarios (with fakes)

| ID | Scenario |
|---|---|
| FCM-001 | Firebase initialization result is surfaced |
| FCM-002 | Android obtains the FCM registration token |
| FCM-003 | Token refresh updates the installation |
| FCM-004 | Android 13+ runtime notification permission is requested |

## E2E Scenarios

| ID | Scenario |
|---|---|
| E2E-NOT-001 | A movement notification intent navigates to Movements (implemented in Commit 5) |

## Test Files

Commit 2 (contracts + RED, no Firebase):

```text
test/features/notifications/
  domain/entities/notification_message_test.dart
  domain/entities/notification_intent_test.dart
  domain/errors/notification_error_test.dart
  presentation/notifiers/notification_notifier_test.dart
test/support/fake_notification_repository.dart
```

Later commits:

```text
test/features/notifications/
  infrastructure/datasources/firebase_messaging_data_source_test.dart   (Commit 3)
  infrastructure/repositories/firebase_notification_repository_test.dart (Commit 3)
  integration/notification_flow_test.dart                                (Commit 5)

integration_test/
  notifications/notification_flow_test.dart                              (Commit 5)
```

## Error Mapping Ownership

- `FirebaseMessagingDataSource` wraps Firebase streams/exceptions.
- `FirebaseNotificationRepository` maps platform outcomes to domain outcomes.
- `NotificationNotifier` maps failures to `NotificationError`:
  - permission not granted -> `NotificationPermissionDenied`.
  - token / messaging failure -> `NotificationUnavailable`.

## Behavior Coverage

- Permission request returns granted/denied without throwing.
- A missing token yields `NotificationUnavailable`, not a crash.
- Token refresh emits the updated token.
- A received message maps to `NotificationMessage`.
- Opening a notification maps to `NotificationIntent`.
- An unsupported payload type maps to `NotificationType.unknown`, not an error.
- A movement intent navigates to Movements in the deterministic E2E.
- Automated tests never contact Firebase and never use a real token.
