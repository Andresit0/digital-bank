import '../domain/entities/notification_message.dart';
import '../domain/errors/notification_error.dart';

sealed class NotificationState {
  const NotificationState();
}

final class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

final class NotificationPermissionPending extends NotificationState {
  const NotificationPermissionPending();
}

final class NotificationReceived extends NotificationState {
  const NotificationReceived(this.message);

  final NotificationMessage message;
}

final class NotificationFailure extends NotificationState {
  const NotificationFailure(this.error);

  final NotificationError error;
}
