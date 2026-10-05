import 'package:digital_bank/app/app.dart';
import 'package:digital_bank/core/config/app_config.dart';
import 'package:digital_bank/core/config/app_config_provider.dart';
import 'package:digital_bank/features/auth/presentation/screens/login_screen.dart';
import 'package:digital_bank/features/movements/presentation/screens/movement_detail_screen.dart';
import 'package:digital_bank/features/movements/presentation/screens/movements_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../support/api_http_server.dart';
import '../support/onboarding_test_support.dart';

const _accounts = [
  {
    'id': 'acc-1',
    'type': 'savings',
    'displayName': 'Savings Account',
    'maskedNumber': '****1234',
    'availableBalance': 1500.5,
  },
];

const _movements = [
  {
    'id': 'mov-1',
    'accountId': 'acc-1',
    'type': 'credit',
    'amount': 500.0,
    'currency': 'USD',
    'description': 'Salary',
    'occurredAt': '2026-10-01T09:30:00.000Z',
  },
  {
    'id': 'mov-2',
    'accountId': 'acc-1',
    'type': 'debit',
    'amount': 125.5,
    'currency': 'USD',
    'description': 'Card purchase',
    'occurredAt': '2026-10-02T12:00:00.000Z',
  },
];

ProviderContainer _containerFor(ApiHttpServer server) {
  return ProviderContainer(
    overrides: [
      appConfigProvider.overrideWithValue(
        AppConfig(apiBaseUrl: server.baseUrl),
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

Future<void> _openMovements(WidgetTester tester) async {
  await _login(tester);
  await tester.tap(find.text('My accounts'));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('account_card_acc-1')));
  await tester.pumpAndSettle();
}

int _movementsRequestCount(ApiHttpServer server) {
  return server.requests
      .where((request) => request.path.endsWith('/movements'))
      .length;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Movements E2E flow', () {
    testWidgets('E2E-MOV-001 reaches movements from an account card', (
      tester,
    ) async {
      final server = await ApiHttpServer.start(
        accounts: _accounts,
        movements: _movements,
      );
      addTearDown(server.close);
      final container = _containerFor(server);
      addTearDown(container.dispose);

      await _pumpApp(tester, container);
      expect(find.byType(LoginScreen), findsOneWidget);

      await _openMovements(tester);

      expect(find.byType(MovementsScreen), findsOneWidget);
      expect(find.byKey(const Key('movement_tile_mov-1')), findsOneWidget);
      expect(find.byKey(const Key('movement_tile_mov-2')), findsOneWidget);

      final movementsRequest = server.requestFor('/accounts/acc-1/movements');
      expect(movementsRequest?.method, 'GET');
      expect(movementsRequest?.authorization, 'Bearer test-access-token');
    });

    testWidgets('E2E-MOV-002 opens the detail without a second request', (
      tester,
    ) async {
      final server = await ApiHttpServer.start(
        accounts: _accounts,
        movements: _movements,
      );
      addTearDown(server.close);
      final container = _containerFor(server);
      addTearDown(container.dispose);

      await _pumpApp(tester, container);
      await _openMovements(tester);

      expect(find.byKey(const Key('movement_tile_mov-1')), findsOneWidget);
      final before = _movementsRequestCount(server);

      await tester.tap(find.byKey(const Key('movement_tile_mov-1')));
      await tester.pumpAndSettle();

      expect(find.byType(MovementDetailScreen), findsOneWidget);
      expect(find.text('Movement details'), findsOneWidget);
      expect(_movementsRequestCount(server), before);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(MovementsScreen), findsOneWidget);
      expect(find.byKey(const Key('movements_invalid_context')), findsNothing);
      expect(find.byKey(const Key('movement_tile_mov-1')), findsOneWidget);
      expect(_movementsRequestCount(server), before);
    });
  });
}
