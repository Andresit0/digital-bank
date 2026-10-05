sealed class NotificationError {
  const NotificationError();

  static const NotificationError permissionDenied =
      NotificationPermissionDenied();
  static const NotificationError unavailable = NotificationUnavailable();
}

final class NotificationPermissionDenied extends NotificationError {
  const NotificationPermissionDenied();
}

final class NotificationUnavailable extends NotificationError {
  const NotificationUnavailable();
}
