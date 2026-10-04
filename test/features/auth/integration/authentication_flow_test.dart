import 'package:dio/dio.dart';
import 'package:digital_bank/app/app.dart';
import 'package:digital_bank/app/di/router/router_provider.dart';
import 'package:digital_bank/core/network/network_providers.dart';
import 'package:digital_bank/core/services/observability/observability_provider.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/interfaces/i_observability.dart';
import 'package:digital_bank/features/auth/presentation/auth_state.dart';
import 'package:digital_bank/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:digital_bank/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/api_test_server.dart';
import '../../../support/fake_observability.dart';

ProviderContainer _containerFor(
  ApiTestServer server, {
  IObservability? observability,
}) {
  return ProviderContainer(
    overrides: [
      dioProvider.overrideWithValue(
        Dio(
          BaseOptions(
            baseUrl: 'http://auth.test',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
          ),
        )..httpClientAdapter = server,
      ),
      if (observability != null)
        observabilityProvider.overrideWithValue(observability),
    ],
  );
}

Future<void> _pumpApp(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MyApp()),
  );
  await tester.pumpAndSettle();
}

Future<void> _submitLogin(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.enterText(find.byKey(const Key('login_email_field')), email);
  await tester.enterText(
    find.byKey(const Key('login_password_field')),
    password,
  );
  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle();
}

void main() {
  group('Authentication integration flow', () {
    testWidgets('INT-AUTH-001 successful login reaches home', (tester) async {
      final server = ApiTestServer.success({
        'accessToken': 'test-access-token',
      });
      final container = _containerFor(server);
      addTearDown(container.dispose);

      await _pumpApp(tester, container);
      expect(find.byType(LoginScreen), findsOneWidget);

      await _submitLogin(
        tester,
        email: 'customer@example.com',
        password: 'secret',
      );

      expect(server.lastRequest?.method, 'POST');
      expect(server.lastRequest?.path, '/auth/login');
      expect(server.lastRequest?.body['email'], 'customer@example.com');
      expect(server.lastRequest?.body['password'], 'secret');
      expect(container.read(authProvider), isA<AuthAuthenticated>());
      expect(find.text('Home'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('INT-AUTH-002 invalid credentials stay on login', (
      tester,
    ) async {
      final server = ApiTestServer.unauthorized();
      final container = _containerFor(server);
      addTearDown(container.dispose);

      await _pumpApp(tester, container);

      await _submitLogin(
        tester,
        email: 'customer@example.com',
        password: 'wrong',
      );

      final state = container.read(authProvider);
      expect(state, isA<AuthFailure>());
      expect(
        (state as AuthFailure).error,
        isA<ApiError>().having((error) => error.statusCode, 'statusCode', 401),
      );
      expect(find.text('Invalid credentials'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('INT-AUTH-003 server error stays on login', (tester) async {
      final server = ApiTestServer.serverError();
      final container = _containerFor(server);
      addTearDown(container.dispose);

      await _pumpApp(tester, container);

      await _submitLogin(
        tester,
        email: 'customer@example.com',
        password: 'secret',
      );

      final state = container.read(authProvider);
      expect(state, isA<AuthFailure>());
      expect(
        (state as AuthFailure).error,
        isA<ApiError>().having((error) => error.statusCode, 'statusCode', 500),
      );
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('INT-AUTH-004 transport failure maps to network error', (
      tester,
    ) async {
      final server = ApiTestServer.closeConnection();
      final container = _containerFor(server);
      addTearDown(container.dispose);

      await _pumpApp(tester, container);

      await _submitLogin(
        tester,
        email: 'customer@example.com',
        password: 'secret',
      );

      final state = container.read(authProvider);
      expect(state, isA<AuthFailure>());
      expect((state as AuthFailure).error, isA<NetworkError>());
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('INT-AUTH-005 logout returns to login', (tester) async {
      final server = ApiTestServer.success({
        'accessToken': 'test-access-token',
      });
      final container = _containerFor(server);
      addTearDown(container.dispose);

      await _pumpApp(tester, container);

      await _submitLogin(
        tester,
        email: 'customer@example.com',
        password: 'secret',
      );
      expect(find.text('Home'), findsOneWidget);

      container.read(authProvider.notifier).logout();
      await tester.pumpAndSettle();

      expect(container.read(authProvider), isNot(isA<AuthAuthenticated>()));
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('INT-AUTH-006 protected route without session redirects', (
      tester,
    ) async {
      final server = ApiTestServer.success({
        'accessToken': 'test-access-token',
      });
      final container = _containerFor(server);
      addTearDown(container.dispose);

      await _pumpApp(tester, container);

      container.read(goRouterProvider).go('/home');
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('OBS-INT-AUTH-WIRING-001 login failure reports event', (
      tester,
    ) async {
      final server = ApiTestServer.unauthorized();
      final observability = FakeObservability();
      final container = _containerFor(server, observability: observability);
      addTearDown(container.dispose);

      await _pumpApp(tester, container);

      await _submitLogin(
        tester,
        email: 'customer@example.com',
        password: 'wrong',
      );

      expect(observability.events, hasLength(1));
      expect(observability.events.single.name, 'auth_login_failed');
    });
  });
}
