import 'package:digital_bank/features/notifications/domain/entities/notification_intent.dart';
import 'package:digital_bank/features/notifications/domain/entities/notification_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationIntent', () {
    test('NOT-005 exposes a navigation intent for a movement', () {
      const intent = NotificationIntent(
        type: NotificationType.movement,
        movementId: 'mov-1',
      );

      expect(intent.type, NotificationType.movement);
      expect(intent.movementId, 'mov-1');
    });

    test('NOT-005 supports value equality', () {
      const a = NotificationIntent(
        type: NotificationType.movement,
        movementId: 'mov-1',
      );
      const b = NotificationIntent(
        type: NotificationType.movement,
        movementId: 'mov-1',
      );

      expect(a, equals(b));
    });
  });
}
