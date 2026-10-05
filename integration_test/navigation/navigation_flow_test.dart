import 'package:digital_bank/app/app.dart';
import 'package:digital_bank/core/config/app_config.dart';
import 'package:digital_bank/core/config/app_config_provider.dart';
import 'package:digital_bank/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:digital_bank/features/auth/presentation/screens/login_screen.dart';
import 'package:digital_bank/features/home/presentation/screens/home_screen.dart';
import 'package:digital_bank/features/movements/presentation/screens/movement_detail_screen.dart';
import 'package:digital_bank/features/movements/presentation/screens/movements_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../support/api_http_server.dart';

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

  group('Navigation E2E flow', () {
    testWidgets('E2E-NAV-001 Accounts -> Movements -> back -> Accounts', (
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

      await _login(tester);
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.text('My accounts'));
      await tester.pumpAndSettle();
      expect(find.byType(AccountsScreen), findsOneWidget);

      await tester.tap(find.byKey(const Key('account_card_acc-1')));
      await tester.pumpAndSettle();
      expect(find.byType(MovementsScreen), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(AccountsScreen), findsOneWidget);
      expect(find.byType(MovementsScreen), findsNothing);
    });

    testWidgets(
      'E2E-NAV-002 Movements -> Movement -> back -> Movements -> back -> Accounts',
      (tester) async {
        final server = await ApiHttpServer.start(
          accounts: _accounts,
          movements: _movements,
        );
        addTearDown(server.close);
        final container = _containerFor(server);
        addTearDown(container.dispose);

        await _pumpApp(tester, container);
        await _login(tester);

        await tester.tap(find.text('My accounts'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('account_card_acc-1')));
        await tester.pumpAndSettle();
        expect(find.byType(MovementsScreen), findsOneWidget);

        await tester.tap(find.byKey(const Key('movement_tile_mov-1')));
        await tester.pumpAndSettle();
        expect(find.byType(MovementDetailScreen), findsOneWidget);

        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byType(MovementsScreen), findsOneWidget);

        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byType(AccountsScreen), findsOneWidget);
      },
    );
    testWidgets(
      'E2E-NAV-003 View movements -> select account -> movements -> back x2',
      (tester) async {
        final server = await ApiHttpServer.start(
          accounts: _accounts,
          movements: _movements,
          experience: const {
            'experience': 'account_home',
            'version': 1,
            'sections': [
              {
                'type': 'quick_action',
                'label': 'View movements',
                'action': 'view_movements',
              },
            ],
          },
        );
        addTearDown(server.close);
        final container = _containerFor(server);
        addTearDown(container.dispose);

        await _pumpApp(tester, container);
        expect(find.byType(LoginScreen), findsOneWidget);

        await _login(tester);
        expect(find.byType(HomeScreen), findsOneWidget);

        await tester.tap(find.text('View movements'));
        await tester.pumpAndSettle();

        expect(find.text('Select an account'), findsOneWidget);

        await tester.tap(find.byKey(const Key('account_card_acc-1')));
        await tester.pumpAndSettle();
        expect(find.byType(MovementsScreen), findsOneWidget);

        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.text('Select an account'), findsOneWidget);

        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );
  });
}
