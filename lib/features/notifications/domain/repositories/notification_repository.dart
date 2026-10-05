import '../entities/notification_intent.dart';
import '../entities/notification_message.dart';

abstract interface class NotificationRepository {
  Future<bool> requestPermission();

  Future<String?> getToken();

  Stream<String> refreshToken();

  Stream<NotificationMessage> onMessage();

  Stream<NotificationIntent> onOpened();
}
