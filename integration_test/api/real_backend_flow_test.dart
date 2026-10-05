import 'dart:io';

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

const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

Future<bool> _isBackendReachable() async {
  final uri = Uri.parse(_baseUrl);
  final host = uri.host.isEmpty ? 'localhost' : uri.host;
  final port = uri.hasPort ? uri.port : 80;
  try {
    final socket = await Socket.connect(
      host,
      port,
      timeout: const Duration(seconds: 1),
    );
    socket.destroy();
    return true;
  } catch (_) {
    return false;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final forced = const bool.fromEnvironment('RUN_REAL_API_E2E');

  group('Real backend E2E', () {
    testWidgets('E2E/API-REAL-001 login then accounts/movements/experience', (
      tester,
    ) async {
      final reachable = await _isBackendReachable();
      if (!forced && !reachable) {
        markTestSkipped('No local backend reachable at $_baseUrl');
        return;
      }
      if (forced && !reachable) {
        fail('RUN_REAL_API_E2E=1 but no backend reachable at $_baseUrl');
      }

      final container = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(apiBaseUrl: _baseUrl),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const MyApp()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);

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

      await tester.tap(find.text('My accounts'));
      await tester.pumpAndSettle();

      expect(find.byType(AccountsScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });
  });
}
