import 'package:dio/dio.dart';
import 'package:digital_bank/core/network/auth_interceptor.dart';
import 'package:digital_bank/core/network/network_providers.dart';
import 'package:digital_bank/core/services/observability/observability_provider.dart';
import 'package:digital_bank/core/session/session_manager.dart';
import 'package:digital_bank/core/session/session_providers.dart';
import 'package:digital_bank/features/accounts/presentation/accounts_state.dart';
import 'package:digital_bank/features/accounts/presentation/notifiers/accounts_notifier.dart';
import 'package:digital_bank/features/auth/domain/entities/auth_session.dart';
import 'package:digital_bank/features/auth/di/auth_providers.dart';
import 'package:digital_bank/features/auth/domain/repositories/auth_repository.dart';
import 'package:digital_bank/features/auth/presentation/auth_state.dart';
import 'package:digital_bank/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:digital_bank/features/experience/presentation/notifiers/experience_notifier.dart';
import 'package:digital_bank/features/experience/presentation/experience_state.dart';
import 'package:digital_bank/features/movements/presentation/movements_state.dart';
import 'package:digital_bank/features/movements/presentation/notifiers/movements_notifier.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/api_test_server.dart';
import '../../../support/fake_observability.dart';

const _token = 'test-access-token';

const _account = {
  'id': 'acc-1',
  'type': 'savings',
  'displayName': 'Savings Account',
  'maskedNumber': '****1234',
  'availableBalance': 1500.5,
};

const _movement = {
  'id': 'mov-1',
  'accountId': 'acc-1',
  'type': 'credit',
  'amount': 500.0,
  'currency': 'USD',
  'description': 'Salary',
  'occurredAt': '2026-10-01T09:30:00.000Z',
};

const _experience = {
  'experience': 'account_home',
  'version': 1,
  'sections': [
    {
      'type': 'promotion',
      'title': 'Save more this month',
      'description': 'Discover our latest promotion',
    },
  ],
};

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this._result);

  final Result<AuthSession> _result;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async => _result;
}

ProviderContainer _containerFor(
  ApiTestServer server, {
  AuthRepository? authRepository,
}) {
  final session = SessionManager();
  final dio = Dio(BaseOptions(baseUrl: 'http://api.test'))
    ..httpClientAdapter = server
    ..interceptors.add(AuthInterceptor(session));
  return ProviderContainer(
    overrides: [
      dioProvider.overrideWithValue(dio),
      sessionManagerProvider.overrideWithValue(session),
      observabilityProvider.overrideWithValue(FakeObservability()),
      if (authRepository != null)
        authRepositoryProvider.overrideWithValue(authRepository),
    ],
  );
}

void main() {
  group('API integration', () {
    test('INT/API-001 login stores the token in the session', () async {
      final server = ApiTestServer.success({'accessToken': _token});
      final container = _containerFor(
        server,
        authRepository: _FakeAuthRepository(
          const Success(AuthSession(accessToken: _token)),
        ),
      );
      addTearDown(container.dispose);

      await container
          .read(authProvider.notifier)
          .login(email: 'customer@example.com', password: 'secret');

      expect(container.read(authProvider), isA<AuthAuthenticated>());
      expect(container.read(sessionManagerProvider).accessToken, _token);
    });

    test('INT/API-002 invalid login leaves no token', () async {
      final server = ApiTestServer.success({'message': 'error'});
      final container = _containerFor(
        server,
        authRepository: _FakeAuthRepository(
          const Failure<AuthSession>(ApiError(statusCode: 401)),
        ),
      );
      addTearDown(container.dispose);

      await container
          .read(authProvider.notifier)
          .login(email: 'customer@example.com', password: 'wrong');

      expect(container.read(authProvider), isA<AuthFailure>());
      expect(container.read(sessionManagerProvider).hasSession, isFalse);
    });

    test('INT/API-003 accounts request carries the bearer token', () async {
      final server = ApiTestServer.protected([
        _account,
      ], requiredBearer: _token);
      final container = _containerFor(server);
      addTearDown(container.dispose);
      container.read(sessionManagerProvider).setToken(_token);

      await container.read(accountsProvider.notifier).load();

      expect(container.read(accountsProvider), isA<AccountsLoaded>());
      expect(server.requestFor('/accounts')?.authorization, 'Bearer $_token');
    });

    test('INT/API-004 a 401 clears the session', () async {
      final server = ApiTestServer.unauthorized();
      final container = _containerFor(server);
      addTearDown(container.dispose);
      container.read(sessionManagerProvider).setToken(_token);

      await container.read(accountsProvider.notifier).load();

      expect(container.read(accountsProvider), isA<AccountsFailure>());
      expect(container.read(sessionManagerProvider).hasSession, isFalse);
    });

    test('INT/API-005 movements request carries the bearer token', () async {
      final server = ApiTestServer.protected([
        _movement,
      ], requiredBearer: _token);
      final container = _containerFor(server);
      addTearDown(container.dispose);
      container.read(sessionManagerProvider).setToken(_token);

      await container.read(movementsProvider.notifier).load(accountId: 'acc-1');

      expect(container.read(movementsProvider), isA<MovementsLoaded>());
      expect(
        server.requestFor('/accounts/acc-1/movements')?.authorization,
        'Bearer $_token',
      );
    });

    test('INT/API-006 experience request carries the bearer token', () async {
      final server = ApiTestServer.protected(
        _experience,
        requiredBearer: _token,
      );
      final container = _containerFor(server);
      addTearDown(container.dispose);
      container.read(sessionManagerProvider).setToken(_token);

      await container.read(experienceProvider.notifier).load();

      expect(container.read(experienceProvider), isA<ExperienceLoaded>());
      expect(
        server.requestFor('/experience/home')?.authorization,
        'Bearer $_token',
      );
    });

    test('E2E/API-001 login then protected requests carry the token', () async {
      final server = ApiTestServer.routed(
        routes: {
          '/accounts': [_account],
          '/accounts/acc-1/movements': [_movement],
          '/experience/home': _experience,
        },
        requiredBearer: _token,
      );
      final container = _containerFor(
        server,
        authRepository: _FakeAuthRepository(
          const Success(AuthSession(accessToken: _token)),
        ),
      );
      addTearDown(container.dispose);
      final session = container.read(sessionManagerProvider);

      expect(session.hasSession, isFalse);

      await container
          .read(authProvider.notifier)
          .login(email: 'customer@example.com', password: 'secret');
      expect(session.hasSession, isTrue);

      await container.read(accountsProvider.notifier).load();
      await container.read(movementsProvider.notifier).load(accountId: 'acc-1');
      await container.read(experienceProvider.notifier).load();

      expect(container.read(accountsProvider), isA<AccountsLoaded>());
      expect(container.read(movementsProvider), isA<MovementsLoaded>());
      expect(container.read(experienceProvider), isA<ExperienceLoaded>());
      expect(server.requestFor('/accounts')?.authorization, 'Bearer $_token');
      expect(
        server.requestFor('/accounts/acc-1/movements')?.authorization,
        'Bearer $_token',
      );
      expect(
        server.requestFor('/experience/home')?.authorization,
        'Bearer $_token',
      );
    });
  });
}
