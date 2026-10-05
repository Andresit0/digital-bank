import 'package:digital_bank/features/notifications/domain/errors/notification_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationError', () {
    test('NOT-006 permissionDenied is a NotificationError', () {
      expect(NotificationError.permissionDenied, isA<NotificationError>());
      expect(
        NotificationError.permissionDenied,
        isA<NotificationPermissionDenied>(),
      );
    });

    test('NOT-006 unavailable is a NotificationError', () {
      expect(NotificationError.unavailable, isA<NotificationError>());
      expect(NotificationError.unavailable, isA<NotificationUnavailable>());
    });

    test('NOT-006 distinguishes the two variants', () {
      expect(
        NotificationError.permissionDenied,
        isNot(isA<NotificationUnavailable>()),
      );
    });
  });
}
