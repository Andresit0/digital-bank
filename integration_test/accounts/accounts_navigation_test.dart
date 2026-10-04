import 'package:digital_bank/app/app.dart';
import 'package:digital_bank/core/config/app_config.dart';
import 'package:digital_bank/core/config/app_config_provider.dart';
import 'package:digital_bank/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:digital_bank/features/auth/presentation/screens/login_screen.dart';
import 'package:digital_bank/features/home/presentation/screens/home_screen.dart';
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

  group('Accounts navigation E2E', () {
    testWidgets('E2E-ACC-001 login reaches home then accounts', (tester) async {
      final server = await ApiHttpServer.start(accounts: const <dynamic>[]);
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
    });
  });
}
