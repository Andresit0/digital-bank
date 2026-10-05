import 'package:digital_bank/app/di/router/router_provider.dart';
import 'package:digital_bank/features/auth/di/auth_providers.dart';
import 'package:digital_bank/features/auth/domain/entities/auth_session.dart';
import 'package:digital_bank/features/auth/domain/repositories/auth_repository.dart';
import 'package:digital_bank/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:digital_bank/features/auth/presentation/screens/login_screen.dart';
import 'package:digital_bank/features/onboarding/di/onboarding_providers.dart';
import 'package:digital_bank/features/onboarding/presentation/notifiers/onboarding_notifier.dart';
import 'package:digital_bank/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_onboarding_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.session});

  final AuthSession? session;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    return Success(session!);
  }
}

ProviderContainer _container({
  required bool onboardingCompleted,
  AuthRepository? authRepository,
}) {
  return ProviderContainer(
    overrides: [
      onboardingRepositoryProvider.overrideWithValue(
        FakeOnboardingRepository(completed: onboardingCompleted),
      ),
      authRepositoryProvider.overrideWithValue(
        authRepository ?? _FakeAuthRepository(),
      ),
    ],
  );
}

Future<void> _pump(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: container.read(goRouterProvider)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Onboarding routing', () {
    testWidgets('ONB-R-001 bootstrap shows onboarding when not completed', (
      tester,
    ) async {
      final container = _container(onboardingCompleted: false);
      addTearDown(container.dispose);
      await container.read(onboardingProvider.notifier).resolve();

      await _pump(tester, container);

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('ONB-R-002 shows login when completed and unauthenticated', (
      tester,
    ) async {
      final container = _container(onboardingCompleted: true);
      addTearDown(container.dispose);
      await container.read(onboardingProvider.notifier).resolve();

      await _pump(tester, container);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });

    testWidgets('ONB-R-003 an authenticated customer reaches home', (
      tester,
    ) async {
      final container = _container(
        onboardingCompleted: true,
        authRepository: _FakeAuthRepository(
          session: const AuthSession(accessToken: 't'),
        ),
      );
      addTearDown(container.dispose);
      await container.read(onboardingProvider.notifier).resolve();
      await container
          .read(authProvider.notifier)
          .login(email: 'customer@example.com', password: 'secret');

      await _pump(tester, container);

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(OnboardingScreen), findsNothing);
    });

    testWidgets('ONB-R-004 logout returns to login, not onboarding', (
      tester,
    ) async {
      final container = _container(
        onboardingCompleted: true,
        authRepository: _FakeAuthRepository(
          session: const AuthSession(accessToken: 't'),
        ),
      );
      addTearDown(container.dispose);
      await container.read(onboardingProvider.notifier).resolve();
      await container
          .read(authProvider.notifier)
          .login(email: 'customer@example.com', password: 'secret');
      await _pump(tester, container);

      container.read(authProvider.notifier).logout();
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
    });
  });
}
