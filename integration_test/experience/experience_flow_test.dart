import 'package:digital_bank/app/app.dart';
import 'package:digital_bank/app/di/router/router_provider.dart';
import 'package:digital_bank/core/config/app_config.dart';
import 'package:digital_bank/core/config/app_config_provider.dart';
import 'package:digital_bank/features/auth/presentation/screens/login_screen.dart';
import 'package:digital_bank/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../support/api_http_server.dart';
import '../support/onboarding_test_support.dart';

const _definitionA = {
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

const _definitionB = {
  'experience': 'account_home',
  'version': 2,
  'sections': [
    {
      'type': 'promotion',
      'title': 'A brand new offer',
      'description': 'Composed dynamically',
    },
  ],
};

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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Experience E2E flow', () {
    testWidgets('E2E-EXP-001 login reaches home with dynamic experience', (
      tester,
    ) async {
      final server = await ApiHttpServer.start(experience: _definitionA);
      addTearDown(server.close);
      final container = _containerFor(server);
      addTearDown(container.dispose);

      await _pumpApp(tester, container);
      expect(find.byType(LoginScreen), findsOneWidget);

      await _login(tester);

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Save more this month'), findsOneWidget);
      expect(find.text('View movements'), findsOneWidget);
      final experienceRequest = server.requestFor('/experience/home');
      expect(experienceRequest?.method, 'GET');
      expect(experienceRequest?.authorization, 'Bearer test-access-token');
    });

    testWidgets('E2E-EXP-002 a changed definition is reflected', (
      tester,
    ) async {
      final server = await ApiHttpServer.start(experience: _definitionA);
      addTearDown(server.close);
      final container = _containerFor(server);
      addTearDown(container.dispose);

      await _pumpApp(tester, container);
      await _login(tester);

      expect(find.text('Save more this month'), findsOneWidget);

      server.experience = _definitionB;
      container.read(goRouterProvider).go('/accounts');
      await tester.pumpAndSettle();
      container.read(goRouterProvider).go('/home');
      await tester.pumpAndSettle();

      expect(find.text('A brand new offer'), findsOneWidget);
      expect(find.text('Save more this month'), findsNothing);
    });
  });
}
