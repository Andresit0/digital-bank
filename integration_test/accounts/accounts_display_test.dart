import 'package:digital_bank/app/app.dart';
import 'package:digital_bank/core/config/app_config.dart';
import 'package:digital_bank/core/config/app_config_provider.dart';
import 'package:digital_bank/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:digital_bank/features/accounts/presentation/screens/home_screen.dart';
import 'package:digital_bank/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../support/api_http_server.dart';

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

  group('Accounts display E2E', () {
    testWidgets('E2E-ACC-002 authenticated customer sees account balances', (
      tester,
    ) async {
      final server = await ApiHttpServer.start(
        accounts: [
          {
            'id': 'acc-1',
            'type': 'savings',
            'displayName': 'Savings Account',
            'maskedNumber': '****1234',
            'availableBalance': 1500.5,
          },
          {
            'id': 'acc-2',
            'type': 'checking',
            'displayName': 'Checking Account',
            'maskedNumber': '****5678',
            'availableBalance': 20.0,
          },
        ],
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
      expect(find.byKey(const Key('account_card_acc-1')), findsOneWidget);
      expect(find.byKey(const Key('account_card_acc-2')), findsOneWidget);
      expect(find.text('\$1,500.50'), findsOneWidget);
      expect(find.text('\$20.00'), findsOneWidget);

      final accountsRequest = server.requestFor('/accounts');
      expect(accountsRequest?.method, 'GET');
    });
  });
}
