import 'package:digital_bank/app/app.dart';
import 'package:digital_bank/core/config/app_config.dart';
import 'package:digital_bank/core/config/app_config_provider.dart';
import 'package:digital_bank/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:digital_bank/features/auth/presentation/screens/login_screen.dart';
import 'package:digital_bank/features/experience/presentation/notifiers/experience_notifier.dart';
import 'package:digital_bank/features/home/presentation/screens/home_screen.dart';
import 'package:digital_bank/features/movements/presentation/screens/movements_screen.dart';
import 'package:digital_bank/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/api_http_server.dart';
import 'support/onboarding_test_support.dart';

const _dynamicExperience = {
  'experience': 'account_home',
  'version': 1,
  'sections': [
    {
      'type': 'promotion',
      'title': 'Save more this month',
      'description': 'Discover our latest promotion',
    },
    {
      'type': 'quick_action',
      'label': 'View movements',
      'action': 'view_movements',
    },
  ],
};

const _accounts = [
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

Future<void> _capture(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  String name,
) async {
  await tester.pump(const Duration(seconds: 1));
  await binding.takeScreenshot(name);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E-VIS-001 captures the customer journey', (tester) async {
    await clearOnboardingCompleted();

    final server = await ApiHttpServer.start(
      accounts: _accounts,
      movements: _movements,
    );
    addTearDown(server.close);
    final container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(
          AppConfig(apiBaseUrl: server.baseUrl),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    await _capture(tester, binding, '01_onboarding');

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    await _capture(tester, binding, '02_login');

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

    expect(find.byType(HomeScreen), findsOneWidget);
    await _capture(tester, binding, '03_home');

    server.experience = _dynamicExperience;
    container.read(experienceProvider.notifier).load();
    await tester.pumpAndSettle();

    expect(find.text('Save more this month'), findsOneWidget);
    await _capture(tester, binding, '04_dynamic_experience');

    await tester.tap(find.text('My accounts'));
    await tester.pumpAndSettle();

    expect(find.byType(AccountsScreen), findsOneWidget);
    await _capture(tester, binding, '05_accounts');

    await tester.tap(find.byKey(const Key('account_card_acc-1')));
    await tester.pumpAndSettle();

    expect(find.byType(MovementsScreen), findsOneWidget);
    await _capture(tester, binding, '06_movements');
  });
}
