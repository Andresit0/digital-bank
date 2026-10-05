import 'package:digital_bank/features/notifications/domain/entities/notification_message.dart';
import 'package:digital_bank/features/notifications/domain/entities/notification_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationMessage', () {
    test('NOT-004 holds type and movementId', () {
      const message = NotificationMessage(
        type: NotificationType.movement,
        movementId: 'mov-1',
      );

      expect(message.type, NotificationType.movement);
      expect(message.movementId, 'mov-1');
    });

    test('NOT-004 allows an unknown type without a movementId', () {
      const message = NotificationMessage(type: NotificationType.unknown);

      expect(message.movementId, isNull);
    });

    test('NOT-004 supports value equality', () {
      const a = NotificationMessage(
        type: NotificationType.movement,
        movementId: 'mov-1',
      );
      const b = NotificationMessage(
        type: NotificationType.movement,
        movementId: 'mov-1',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
