# Contracts: Notifications (Firebase Cloud Messaging)

## Internal Boundary

```text
NotificationNotifier (presentation)
    |
    v
NotificationRepository (domain)
    |
    v
FirebaseNotificationRepository (infrastructure)
    |
    v
FirebaseMessagingDataSource (infrastructure)
    |
    v
firebase_messaging / Firebase
```

Registration with the backend:

```text
NotificationNotifier
    |
    v
NotificationsRemoteDataSource
    |
    v
POST /notifications/register
    |
    v
NestJS -> DeviceInstallation
```

Dependency direction:

```text
presentation   -> domain
infrastructure -> domain
infrastructure -> firebase_messaging
infrastructure -> core/network + shared/error
notifications  -> must NOT depend on accounts, movements, or experience
```

## Firebase Mechanisms Mapping

Firebase distinguishes foreground, background-open, and terminated-launch
mechanisms. Infrastructure maps them into the domain contract:

```text
firebase_messaging.onMessage              -> onMessage()
firebase_messaging.onMessageOpenedApp     -> onOpened()   (background)
firebase_messaging.getInitialMessage()    -> onOpened()   (terminated launch)
firebase_messaging.onTokenRefresh         -> refreshToken()
firebase_messaging.getToken()             -> getToken()
firebase_messaging.requestPermission()    -> requestPermission()
```

The domain exposes a single `onOpened()` stream; the two Firebase open
mechanisms are collapsed there.

## Device Registration Contract

```text
POST /notifications/register

Request:
{
  "firebaseInstallationId": String?,
  "fcmRegistrationToken": String,
  "platform": "android"
}

Response 200 / 201:
{
  "id": String
}

Protected endpoint: requires Authorization: Bearer <accessToken>.
The access token is attached centrally by the shared API client; the feature
never reads or builds it. See docs/architecture/pr18-api-integration.md.
```

`firebaseInstallationId` and `fcmRegistrationToken` are technical delivery
credentials. They are never logged, returned in unnecessary responses, or
committed as real fixtures. Tests use synthetic values such as
`fake-fcm-registration-token`.

## Notification Payload Contract

```json
{ "type": "movement", "movementId": "..." }
```

The payload contains no JWT, access token, FCM token, credentials, or financial
data. `type` and `movementId` are the only routing fields.

## Layer Responsibilities

```text
FirebaseMessagingDataSource        ->  Firebase streams <-> domain messages
FirebaseNotificationRepository     ->  platform outcomes <-> domain outcomes
NotificationsRemoteDataSource      ->  HTTP request/response for registration
NotificationNotifier               ->  AppError -> NotificationError; navigation intent
```

The `notifications` feature only produces a `NotificationIntent`. Resolving that
intent (for example, navigating to Movements) is the responsibility of the
application/router layer. The feature never imports `accounts`, `movements`, or
`go_router`.

## Error Mapping

```text
permission denied            -> NotificationPermissionDenied
token unavailable / failure  -> NotificationUnavailable
transport failure            -> NotificationUnavailable
```

Permission denial and token unavailability never throw into presentation; they
are represented as states.
