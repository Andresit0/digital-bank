import 'package:digital_bank/core/services/logging/logging_providers.dart';
import 'package:digital_bank/core/services/observability/observability_provider.dart';
import 'package:digital_bank/core/session/session_providers.dart';
import 'package:digital_bank/features/auth/di/auth_providers.dart';
import 'package:digital_bank/features/auth/domain/entities/auth_session.dart';
import 'package:digital_bank/features/auth/domain/repositories/auth_repository.dart';
import 'package:digital_bank/features/auth/presentation/auth_state.dart';
import 'package:digital_bank/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/interfaces/i_logger.dart';
import 'package:digital_bank/shared/interfaces/i_observability.dart';
import 'package:digital_bank/shared/observability/observability_severity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fake_observability.dart';
import '../../../../support/observability_policy.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.result});

  final Result<AuthSession>? result;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    return result!;
  }
}

class _ThrowingLogger implements ILogger {
  @override
  void info(String message, {String? technicalMessage}) {
    throw StateError(
      'ILogger.info must not be called for a reportable failure',
    );
  }

  @override
  void error(
    String message, {
    Object? technicalMessage,
    StackTrace? stackTrace,
  }) {
    throw StateError(
      'ILogger.error must not be called for a reportable failure',
    );
  }
}

ProviderContainer _containerWith(
  AuthRepository repository, {
  IObservability? observability,
  ILogger? logger,
}) {
  return ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      if (observability != null)
        observabilityProvider.overrideWithValue(observability),
      if (logger != null) loggerProvider.overrideWithValue(logger),
    ],
  );
}

void main() {
  group('AuthNotifier', () {
    test('AUTH-NOT-001 starts in the initial state', () {
      final container = _containerWith(_FakeAuthRepository());
      addTearDown(container.dispose);

      expect(container.read(authProvider), isA<AuthInitial>());
    });

    test('AUTH-NOT-002 success emits loading then authenticated', () async {
      final observability = FakeObservability();
      final container = _containerWith(
        _FakeAuthRepository(
          result: const Success(AuthSession(accessToken: 'token-123')),
        ),
        observability: observability,
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
      expect(observability.events, isEmpty);
    });

    test(
      'AUTH-NOT-003 401 emits loading then failure with ApiError 401',
      () async {
        final container = _containerWith(
          _FakeAuthRepository(
            result: const Failure<AuthSession>(ApiError(statusCode: 401)),
          ),
        );
        addTearDown(container.dispose);

        await container
            .read(authProvider.notifier)
            .login(email: 'customer@example.com', password: 'wrong');

        final state = container.read(authProvider);
        expect(state, isA<AuthFailure>());
        final error = (state as AuthFailure).error;
        expect(error, isA<ApiError>());
        expect((error as ApiError).statusCode, 401);
      },
    );

    test(
      'AUTH-NOT-004 network failure emits failure with NetworkError',
      () async {
        final container = _containerWith(
          _FakeAuthRepository(
            result: const Failure<AuthSession>(NetworkError()),
          ),
        );
        addTearDown(container.dispose);

        await container
            .read(authProvider.notifier)
            .login(email: 'customer@example.com', password: 'secret');

        final state = container.read(authProvider);
        expect(state, isA<AuthFailure>());
        expect((state as AuthFailure).error, isA<NetworkError>());
      },
    );

    test(
      'AUTH-NOT-005 failure reports exactly one event and does not use ILogger',
      () async {
        final observability = FakeObservability();
        final container = _containerWith(
          _FakeAuthRepository(
            result: const Failure<AuthSession>(NetworkError()),
          ),
          observability: observability,
          logger: _ThrowingLogger(),
        );
        addTearDown(container.dispose);

        await container
            .read(authProvider.notifier)
            .login(email: 'customer@example.com', password: 'secret');

        expect(observability.events, hasLength(1));
      },
    );

    test('AUTH-NOT-006 captured auth events respect the policy', () async {
      final observability = FakeObservability();
      final container = _containerWith(
        _FakeAuthRepository(result: const Failure<AuthSession>(NetworkError())),
        observability: observability,
      );
      addTearDown(container.dispose);

      await container
          .read(authProvider.notifier)
          .login(
            email: 'customer@example.com',
            password: 'super-secret-password',
          );

      expectEventsRespectSensitiveDataPolicy(observability.events);
    });

    test('AUTH-NOT-007 logout returns to unauthenticated', () async {
      final container = _containerWith(
        _FakeAuthRepository(
          result: const Success(AuthSession(accessToken: 'token-123')),
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

    test(
      'OBS-INT-AUTH-001 401 reports auth_login_failed with metadata',
      () async {
        final observability = FakeObservability();
        final container = _containerWith(
          _FakeAuthRepository(
            result: const Failure<AuthSession>(ApiError(statusCode: 401)),
          ),
          observability: observability,
        );
        addTearDown(container.dispose);

        await container
            .read(authProvider.notifier)
            .login(email: 'customer@example.com', password: 'wrong');

        final event = observability.events.single;
        expect(event.name, 'auth_login_failed');
        expect(event.severity, ObservabilitySeverity.warning);
        expect(event.metadata['errorType'], 'ApiError');
        expect(event.metadata['statusCode'], 401);
      },
    );

    test(
      'OBS-INT-AUTH-002 network failure reports auth_login_failed',
      () async {
        final observability = FakeObservability();
        final container = _containerWith(
          _FakeAuthRepository(
            result: const Failure<AuthSession>(NetworkError()),
          ),
          observability: observability,
        );
        addTearDown(container.dispose);

        await container
            .read(authProvider.notifier)
            .login(email: 'customer@example.com', password: 'secret');

        final event = observability.events.single;
        expect(event.name, 'auth_login_failed');
        expect(event.metadata['errorType'], 'NetworkError');
        expect(event.metadata.containsKey('statusCode'), isFalse);
      },
    );

    test('OBS-INT-AUTH-003 logout reports auth_logout', () async {
      final observability = FakeObservability();
      final container = _containerWith(
        _FakeAuthRepository(
          result: const Success(AuthSession(accessToken: 'token-123')),
        ),
        observability: observability,
      );
      addTearDown(container.dispose);

      await container
          .read(authProvider.notifier)
          .login(email: 'customer@example.com', password: 'secret');

      container.read(authProvider.notifier).logout();

      final event = observability.events.single;
      expect(event.name, 'auth_logout');
      expect(event.severity, ObservabilitySeverity.info);
      expect(event.metadata, isEmpty);
    });

    test('API-001 successful login stores the token in the session', () async {
      final container = _containerWith(
        _FakeAuthRepository(
          result: const Success(AuthSession(accessToken: 'token-123')),
        ),
      );
      addTearDown(container.dispose);

      final session = container.read(sessionManagerProvider);
      expect(session.hasSession, isFalse);

      await container
          .read(authProvider.notifier)
          .login(email: 'customer@example.com', password: 'secret');

      expect(session.hasSession, isTrue);
      expect(session.accessToken, 'token-123');
    });

    test('API-002 invalid login does not store a token', () async {
      final container = _containerWith(
        _FakeAuthRepository(
          result: const Failure<AuthSession>(ApiError(statusCode: 401)),
        ),
      );
      addTearDown(container.dispose);

      await container
          .read(authProvider.notifier)
          .login(email: 'customer@example.com', password: 'wrong');

      expect(container.read(sessionManagerProvider).hasSession, isFalse);
    });

    test('API-004 logout clears the session token', () async {
      final container = _containerWith(
        _FakeAuthRepository(
          result: const Success(AuthSession(accessToken: 'token-123')),
        ),
      );
      addTearDown(container.dispose);

      await container
          .read(authProvider.notifier)
          .login(email: 'customer@example.com', password: 'secret');

      final session = container.read(sessionManagerProvider);
      expect(session.hasSession, isTrue);

      container.read(authProvider.notifier).logout();

      expect(session.hasSession, isFalse);
      expect(session.accessToken, isNull);
    });
  });
}
