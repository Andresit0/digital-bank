import 'package:digital_bank/features/auth/domain/entities/auth_session.dart';
import 'package:digital_bank/features/auth/domain/errors/auth_error.dart';
import 'package:digital_bank/features/auth/domain/repositories/auth_repository.dart';
import 'package:digital_bank/features/auth/presentation/auth_state.dart';
import 'package:digital_bank/features/auth/di/auth_providers.dart';
import 'package:digital_bank/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.session, this.error});

  final AuthSession? session;
  final Object? error;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    if (error != null) {
      throw error!;
    }
    return session!;
  }
}

ProviderContainer _containerWith(AuthRepository repository) {
  return ProviderContainer(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
  );
}

void main() {
  group('AuthNotifier', () {
    test('starts in the initial state', () {
      final container = _containerWith(_FakeAuthRepository());
      addTearDown(container.dispose);

      expect(container.read(authProvider), isA<AuthInitial>());
    });

    test('emits loading then authenticated on successful login', () async {
      final container = _containerWith(
        _FakeAuthRepository(
          session: const AuthSession(accessToken: 'token-123'),
        ),
      );
      addTearDown(container.dispose);

      final future = container
          .read(authProvider.notifier)
          .login(email: 'customer@example.com', password: 'secret');

      expect(container.read(authProvider), isA<AuthLoading>());

      await future;

      final state = container.read(authProvider);
      expect(state, isA<AuthAuthenticated>());
      expect((state as AuthAuthenticated).session.accessToken, 'token-123');
    });

    test('emits loading then failure on invalid credentials', () async {
      final container = _containerWith(
        _FakeAuthRepository(error: AuthError.invalidCredentials),
      );
      addTearDown(container.dispose);

      await container
          .read(authProvider.notifier)
          .login(email: 'customer@example.com', password: 'wrong');

      final state = container.read(authProvider);
      expect(state, isA<AuthFailure>());
      expect((state as AuthFailure).error, AuthError.invalidCredentials);
    });

    test('emits loading then failure on network error', () async {
      final container = _containerWith(
        _FakeAuthRepository(error: AuthError.network),
      );
      addTearDown(container.dispose);

      await container
          .read(authProvider.notifier)
          .login(email: 'customer@example.com', password: 'secret');

      expect(container.read(authProvider), isA<AuthFailure>());
    });

    test('logout returns to unauthenticated', () async {
      final container = _containerWith(
        _FakeAuthRepository(
          session: const AuthSession(accessToken: 'token-123'),
        ),
      );
      addTearDown(container.dispose);

      await container
          .read(authProvider.notifier)
          .login(email: 'customer@example.com', password: 'secret');
      expect(container.read(authProvider), isA<AuthAuthenticated>());

      container.read(authProvider.notifier).logout();
      expect(container.read(authProvider), isA<AuthUnauthenticated>());
    });
  });
}
