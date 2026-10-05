import 'package:digital_bank/features/notifications/domain/entities/notification_type.dart';
import 'package:digital_bank/features/notifications/infrastructure/datasources/firebase_messaging_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fake_firebase_messaging_adapter.dart';

void main() {
  group('FirebaseMessagingDataSource', () {
    test('FCM-004 a granted permission is reported', () async {
      final adapter = FakeFirebaseMessagingAdapter(permissionGranted: true);
      final dataSource = FirebaseMessagingDataSourceImpl(adapter);

      expect(await dataSource.requestPermission(), isTrue);
    });

    test('FCM-004 a denied permission is reported', () async {
      final adapter = FakeFirebaseMessagingAdapter(permissionGranted: false);
      final dataSource = FirebaseMessagingDataSourceImpl(adapter);

      expect(await dataSource.requestPermission(), isFalse);
    });

    test('FCM-002 the token is obtained', () async {
      final adapter = FakeFirebaseMessagingAdapter(
        token: 'fake-fcm-registration-token',
      );
      final dataSource = FirebaseMessagingDataSourceImpl(adapter);

      expect(await dataSource.getToken(), 'fake-fcm-registration-token');
    });

    test('FCM-003 token refresh is propagated', () async {
      final adapter = FakeFirebaseMessagingAdapter();
      final dataSource = FirebaseMessagingDataSourceImpl(adapter);

      final future = dataSource.refreshToken().first;
      await Future<void>.delayed(Duration.zero);
      adapter.emitTokenRefresh('rotated-token');

      expect(await future, 'rotated-token');
    });

    test('NOT-004 a movement message maps to a domain message', () async {
      final adapter = FakeFirebaseMessagingAdapter();
      final dataSource = FirebaseMessagingDataSourceImpl(adapter);

      final future = dataSource.onMessage().first;
      adapter.emitMessage(
        const NotificationPayload(type: 'movement', movementId: 'mov-1'),
      );

      final message = await future;
      expect(message.type, NotificationType.movement);
      expect(message.movementId, 'mov-1');
    });

    test('NOT-004 an unsupported type maps to unknown', () async {
      final adapter = FakeFirebaseMessagingAdapter();
      final dataSource = FirebaseMessagingDataSourceImpl(adapter);

      final future = dataSource.onMessage().first;
      adapter.emitMessage(const NotificationPayload(type: 'other'));

      expect((await future).type, NotificationType.unknown);
    });

    test('NOT-005 a terminated launch exposes the initial message', () async {
      final adapter = FakeFirebaseMessagingAdapter()
        ..initialMessage = const NotificationPayload(
          type: 'movement',
          movementId: 'mov-9',
        );
      final dataSource = FirebaseMessagingDataSourceImpl(adapter);

      final intent = await dataSource.onOpened().first;
      expect(intent.type, NotificationType.movement);
      expect(intent.movementId, 'mov-9');
    });

    test('NOT-005 a background open exposes an intent', () async {
      final adapter = FakeFirebaseMessagingAdapter();
      final dataSource = FirebaseMessagingDataSourceImpl(adapter);

      final future = dataSource.onOpened().first;
      await Future<void>.delayed(Duration.zero);
      adapter.emitOpened(
        const NotificationPayload(type: 'movement', movementId: 'mov-1'),
      );

      expect((await future).movementId, 'mov-1');
    });

    test('NOT-005 an opened event is not lost while resolving the initial '
        'message', () async {
      final adapter = FakeFirebaseMessagingAdapter()
        ..initialMessage = const NotificationPayload(
          type: 'movement',
          movementId: 'mov-initial',
        );
      final dataSource = FirebaseMessagingDataSourceImpl(adapter);

      final intents = <String?>[];
      final subscription = dataSource.onOpened().listen(
        (intent) => intents.add(intent.movementId),
      );

      adapter.emitOpened(
        const NotificationPayload(type: 'movement', movementId: 'mov-bg'),
      );
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(intents, contains('mov-bg'));
      expect(intents, contains('mov-initial'));
    });
  });
}
