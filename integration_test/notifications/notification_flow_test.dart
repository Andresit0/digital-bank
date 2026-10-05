import 'dart:async';

import 'package:digital_bank/app/app.dart';
import 'package:digital_bank/core/config/app_config.dart';
import 'package:digital_bank/core/config/app_config_provider.dart';
import 'package:digital_bank/features/auth/presentation/screens/login_screen.dart';
import 'package:digital_bank/features/home/presentation/screens/home_screen.dart';
import 'package:digital_bank/features/notifications/di/notification_providers.dart';
import 'package:digital_bank/features/notifications/domain/entities/notification_intent.dart';
import 'package:digital_bank/features/notifications/domain/entities/notification_message.dart';
import 'package:digital_bank/features/notifications/domain/entities/notification_type.dart';
import 'package:digital_bank/features/notifications/domain/repositories/notification_repository.dart';
import 'package:digital_bank/features/notifications/infrastructure/datasources/notifications_remote_data_source.dart';
import 'package:digital_bank/features/movements/presentation/screens/movements_screen.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../support/api_http_server.dart';
import '../support/onboarding_test_support.dart';

class _FakeNotificationRepository implements NotificationRepository {
  final _refresh = StreamController<String>.broadcast();
  final _messages = StreamController<NotificationMessage>.broadcast();
  final _opened = StreamController<NotificationIntent>.broadcast();

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<String?> getToken() async => 'fake-fcm-registration-token';

  @override
  Stream<String> refreshToken() => _refresh.stream;

  @override
  Stream<NotificationMessage> onMessage() => _messages.stream;

  @override
  Stream<NotificationIntent> onOpened() => _opened.stream;

  void emitOpened(NotificationIntent intent) => _opened.add(intent);
}

class _FakeRemoteDataSource implements NotificationsRemoteDataSource {
  @override
  Future<Result<void>> register({
    required String token,
    required String platform,
  }) async => const Success<void>(null);
}

ProviderContainer _containerFor(ApiHttpServer server) {
  return ProviderContainer(
    overrides: [
      appConfigProvider.overrideWithValue(
        AppConfig(apiBaseUrl: server.baseUrl),
      ),
      notificationRepositoryProvider.overrideWithValue(
        _FakeNotificationRepository(),
      ),
      notificationsRemoteDataSourceProvider.overrideWithValue(
        _FakeRemoteDataSource(),
      ),
    ],
  );
}

Future<void> _pumpApp(WidgetTester tester, ProviderContainer container) async {
  await seedOnboardingCompleted();
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MyApp()),
  );
  await tester.pumpAndSettle();
}

Future<void> _login(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const Key('login_email_field')),
    'customer@example.com',
  );
  await tester.enterText(
    find.byKey(const Key('login_password_field')),
    'secret',
  );
  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Notification E2E flow', () {
    testWidgets('E2E-NOT-001 a movement intent navigates to Movements', (
      tester,
    ) async {
      final server = await ApiHttpServer.start(accounts: const <dynamic>[]);
      addTearDown(server.close);
      final container = _containerFor(server);
      addTearDown(container.dispose);

      await _pumpApp(tester, container);
      expect(find.byType(LoginScreen), findsOneWidget);

      await _login(tester);
      expect(find.byType(HomeScreen), findsOneWidget);

      final repository = container.read(
        notificationRepositoryProvider,
      ) as _FakeNotificationRepository;
      repository.emitOpened(
        const NotificationIntent(
          type: NotificationType.movement,
          movementId: 'mov-1',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MovementsScreen), findsOneWidget);
    });
  });
}
