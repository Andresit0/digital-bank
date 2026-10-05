import 'notification_type.dart';

class NotificationMessage {
  const NotificationMessage({required this.type, this.movementId});

  final NotificationType type;
  final String? movementId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationMessage &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          movementId == other.movementId;

  @override
  int get hashCode => Object.hash(type, movementId);

  @override
  String toString() =>
      'NotificationMessage(type: $type, movementId: $movementId)';
}
