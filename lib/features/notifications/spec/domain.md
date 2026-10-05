# Domain: Notifications (Firebase Cloud Messaging)

## Entities

### NotificationMessage

- type: NotificationType
- movementId: String?

`NotificationMessage` is pure Dart. It does not depend on Flutter, Firebase, or
any transport type. It carries only minimal, non-sensitive routing data.

### NotificationIntent

- type: NotificationType
- movementId: String?

`NotificationIntent` represents where the customer should be taken when a
notification is opened. It contains no tokens, credentials, or financial data.

## Enums

### NotificationType

```text
NotificationType
  movement
  unknown
```

`NotificationType.unknown` is used when a received payload uses an unsupported
type. It is not an error; it is an unroutable notification.

## Repository Contract

```dart
abstract interface class NotificationRepository {
  Future<bool> requestPermission();
  Future<String?> getToken();
  Stream<String> refreshToken();
  Stream<NotificationMessage> onMessage();
  Stream<NotificationIntent> onOpened();
}
```

`NotificationRepository` is the domain entry point for notifications. It depends
on no Firebase type. The FCM token is an infrastructure credential used to
register the device installation. It is never part of `NotificationState`,
rendered, logged, persisted in Flutter domain state, or included in notification
payloads.

## Domain Errors

```text
sealed class NotificationError
  NotificationPermissionDenied
  NotificationUnavailable
```

Mapping:

```text
permission not granted            -> NotificationPermissionDenied
token / messaging failure         -> NotificationUnavailable
```

`NotificationError` is the feature-level failure abstraction exposed to
Presentation. It does not replace `AppError` as the infrastructure error model.

Chain:

```text
FirebaseMessaging / transport
    |
    v
AppError or platform exception
    |
    v
NotificationRepository
    |
    v
NotificationError
    |
    v
NotificationState
```

## Presentation State

`NotificationState` belongs to Presentation, not to Domain:

```text
sealed class NotificationState
  NotificationInitial
  NotificationPermissionPending
  NotificationReceived(NotificationMessage)
  NotificationFailure(NotificationError)
```

## Rules

- The domain does not import Flutter, Firebase, or go_router.
- The domain does not know about Firebase Messaging mechanisms; the
  infrastructure maps `onMessage`, `onMessageOpenedApp`, and `getInitialMessage`
  into `onMessage()` and `onOpened()`.
- The domain never carries the FCM token, FID, JWT, or financial data.
- Navigation is expressed as an intent; the router resolves it.
- There are no use cases: the only domain behavior is exposing notification
  permission, token, and interaction streams.
