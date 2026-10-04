import 'package:digital_bank/app/di/router/router_provider.dart';
import 'package:digital_bank/features/auth/domain/entities/auth_session.dart';
import 'package:digital_bank/features/auth/domain/repositories/auth_repository.dart';
import 'package:digital_bank/features/auth/presentation/auth_state.dart';
import 'package:digital_bank/features/auth/di/auth_providers.dart';
import 'package:digital_bank/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:digital_bank/features/auth/presentation/screens/login_screen.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

ProviderContainer _container(AuthRepository repository) {
  return ProviderContainer(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
  );
}

void main() {
  group('Auth routing', () {
    testWidgets('unauthenticated user opening /home is redirected to login', (
      tester,
    ) async {
      final container = _container(_FakeAuthRepository());
      addTearDown(container.dispose);

      final router = container.read(goRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(authProvider), isNot(isA<AuthAuthenticated>()));

      router.go('/home');
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('authenticated user reaches /home', (tester) async {
      final container = _container(
        _FakeAuthRepository(session: const AuthSession(accessToken: 't')),
      );
      addTearDown(container.dispose);

      await container
          .read(authProvider.notifier)
          .login(email: 'customer@example.com', password: 'secret');
      expect(container.read(authProvider), isA<AuthAuthenticated>());

      final router = container.read(goRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      router.go('/home');
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsNothing);
    });
  });
}
