import 'package:digital_bank/features/notifications/domain/entities/notification_intent.dart';
import 'package:digital_bank/features/notifications/domain/entities/notification_message.dart';
import 'package:digital_bank/features/notifications/domain/entities/notification_type.dart';
import 'package:digital_bank/features/notifications/domain/errors/notification_error.dart';
import 'package:digital_bank/features/notifications/di/notification_providers.dart';
import 'package:digital_bank/features/notifications/presentation/notification_state.dart';
import 'package:digital_bank/features/notifications/presentation/notifiers/notification_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fake_notification_repository.dart';
import '../../../../support/fake_notifications_remote_data_source.dart';

ProviderContainer _containerWith(
  FakeNotificationRepository repository, {
  FakeNotificationsRemoteDataSource? remote,
}) {
  return ProviderContainer(
    overrides: [
      notificationRepositoryProvider.overrideWithValue(repository),
      notificationsRemoteDataSourceProvider.overrideWithValue(
        remote ?? FakeNotificationsRemoteDataSource(),
      ),
    ],
  );
}

void main() {
  group('NotificationNotifier', () {
    test('NOT-001 starts in the initial state', () {
      final container = _containerWith(FakeNotificationRepository());
      addTearDown(container.dispose);

      expect(container.read(notificationProvider), isA<NotificationInitial>());
    });

    test('NOT-001 a granted permission leaves the notifier ready', () async {
      final repository = FakeNotificationRepository(permissionGranted: true);
      final container = _containerWith(repository);
      addTearDown(container.dispose);

      final granted = await container
          .read(notificationProvider.notifier)
          .requestPermission();

      expect(granted, isTrue);
      expect(container.read(notificationProvider), isA<NotificationInitial>());
    });

    test('NOT-006 a denied permission maps to permissionDenied', () async {
      final repository = FakeNotificationRepository(permissionGranted: false);
      final container = _containerWith(repository);
      addTearDown(container.dispose);

      await container.read(notificationProvider.notifier).requestPermission();

      final state = container.read(notificationProvider);
      expect(state, isA<NotificationFailure>());
      expect(
        (state as NotificationFailure).error,
        isA<NotificationPermissionDenied>(),
      );
    });

    test('NOT-006 a missing token maps to unavailable', () async {
      final repository = FakeNotificationRepository(token: null);
      final container = _containerWith(repository);
      addTearDown(container.dispose);

      await container.read(notificationProvider.notifier).loadToken();

      final state = container.read(notificationProvider);
      expect(state, isA<NotificationFailure>());
      expect(
        (state as NotificationFailure).error,
        isA<NotificationUnavailable>(),
      );
    });

    test('NOT-002 a present token leaves no failure', () async {
      final repository = FakeNotificationRepository(
        token: 'fake-fcm-registration-token',
      );
      final container = _containerWith(repository);
      addTearDown(container.dispose);

      await container.read(notificationProvider.notifier).loadToken();

      expect(
        container.read(notificationProvider),
        isNot(isA<NotificationFailure>()),
      );
    });

    test('NOT-004 an incoming message updates the received state', () async {
      final repository = FakeNotificationRepository();
      final container = _containerWith(repository);
      addTearDown(container.dispose);
      addTearDown(repository.dispose);

      container.read(notificationProvider.notifier).listen();

      repository.emitMessage(
        const NotificationMessage(
          type: NotificationType.movement,
          movementId: 'mov-1',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      final state = container.read(notificationProvider);
      expect(state, isA<NotificationReceived>());
      expect((state as NotificationReceived).message.movementId, 'mov-1');
    });

    test('NOT-005 an opened intent is exposed for the router', () async {
      final repository = FakeNotificationRepository();
      final container = _containerWith(repository);
      addTearDown(container.dispose);
      addTearDown(repository.dispose);

      var captured = '';
      container.read(notificationProvider.notifier).onIntent = (intent) {
        captured = intent.movementId ?? '';
      };

      container.read(notificationProvider.notifier).listen();

      repository.emitOpened(
        const NotificationIntent(
          type: NotificationType.movement,
          movementId: 'mov-9',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(captured, 'mov-9');
    });

    test('API-NTF-002 loadToken registers the token remotely', () async {
      final repository = FakeNotificationRepository(
        token: 'fake-fcm-registration-token',
      );
      final remote = FakeNotificationsRemoteDataSource();
      final container = _containerWith(repository, remote: remote);
      addTearDown(container.dispose);

      await container.read(notificationProvider.notifier).loadToken();

      expect(remote.registered, hasLength(1));
      expect(remote.registered.single.token, 'fake-fcm-registration-token');
      expect(remote.registered.single.platform, 'android');
      expect(container.read(notificationProvider), isA<NotificationInitial>());
    });

    test('API-NTF-011 a registration failure does not crash', () async {
      final repository = FakeNotificationRepository(token: 'token-a');
      final remote = FakeNotificationsRemoteDataSource(fail: true);
      final container = _containerWith(repository, remote: remote);
      addTearDown(container.dispose);

      await container.read(notificationProvider.notifier).loadToken();

      expect(container.read(notificationProvider), isA<NotificationFailure>());
    });

    test('start registers the token and re-registers on refresh', () async {
      final repository = FakeNotificationRepository(token: 'token-a');
      final remote = FakeNotificationsRemoteDataSource();
      final container = _containerWith(repository, remote: remote);
      addTearDown(container.dispose);

      await container.read(notificationProvider.notifier).start();
      expect(remote.registered, hasLength(1));

      repository.emitTokenRefresh('token-b');
      await Future<void>.delayed(Duration.zero);

      expect(remote.registered, hasLength(2));
      expect(remote.registered.last.token, 'token-b');
    });

    test('start requests permission before registering', () async {
      final repository = FakeNotificationRepository(token: 'token-a');
      final remote = FakeNotificationsRemoteDataSource();
      final container = _containerWith(repository, remote: remote);
      addTearDown(container.dispose);

      await container.read(notificationProvider.notifier).start();

      expect(repository.permissionRequests, 1);
      expect(remote.registered, hasLength(1));
    });

    test('start with denied permission does not register', () async {
      final repository = FakeNotificationRepository(
        permissionGranted: false,
        token: 'token-a',
      );
      final remote = FakeNotificationsRemoteDataSource();
      final container = _containerWith(repository, remote: remote);
      addTearDown(container.dispose);

      await container.read(notificationProvider.notifier).start();

      expect(repository.permissionRequests, 1);
      expect(remote.registered, isEmpty);
      final state = container.read(notificationProvider);
      expect(state, isA<NotificationFailure>());
      expect(
        (state as NotificationFailure).error,
        isA<NotificationPermissionDenied>(),
      );
    });
  });
}
