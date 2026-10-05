import 'notification_type.dart';

class NotificationIntent {
  const NotificationIntent({required this.type, this.movementId});

  final NotificationType type;
  final String? movementId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationIntent &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          movementId == other.movementId;

  @override
  int get hashCode => Object.hash(type, movementId);

  @override
  String toString() =>
      'NotificationIntent(type: $type, movementId: $movementId)';
}
