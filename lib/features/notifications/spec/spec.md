# Feature: Notifications (Firebase Cloud Messaging)

## Purpose

Integrate Firebase Cloud Messaging (FCM) as a real external service so the
application can receive a financial notification on an Android device and, when
the customer taps it, reach an existing journey (Movement detail within
Movements), without coupling the notification domain to Firebase.

## Scope

- Initialize FCM on Android.
- Request the notification permission at runtime on Android 13+.
- Obtain and refresh the FCM registration token.
- Register the device installation with the NestJS backend.
- Receive foreground, background, and terminated-launch notifications.
- Convert an incoming notification into a domain notification.
- Express a non-sensitive navigation intent from a notification.
- Keep notification failures from crashing the application.

## Out of Scope

- iOS and APNs configuration.
- Sending notifications from the device.
- Rich media, custom notification UI, or in-app message centers.
- End-to-end encryption of notification content.
- Personalization, segmentation, feature flags, or A/B testing.
- Backend deployment and Firebase Functions.

## Actors

- Authenticated customer.
- Firebase Cloud Messaging (external service).
- NestJS backend (notification sender through the Firebase Admin SDK).

## Main Flow

```text
Android device
    |
    | FirebaseMessaging.getToken()
    v
NotificationRepository
    |
    | POST /notifications/register
    v
NestJS -> DeviceInstallation
    |
    | (later) firebase-admin -> FCM -> Android
    v
Notification (foreground / background / terminated)
    |
    | tap
    v
Navigation intent -> Movements / Movement detail
```

## States

```text
NotificationInitial
NotificationPermissionPending
NotificationReceived
NotificationFailure
```

`NotificationInitial` is the resting state. A missing token or a denied
permission is not a crash; it is represented and handled.
