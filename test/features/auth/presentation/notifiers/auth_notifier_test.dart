import 'package:digital_bank/core/services/logging/logging_providers.dart';
import 'package:digital_bank/features/auth/di/auth_providers.dart';
import 'package:digital_bank/features/auth/domain/entities/auth_session.dart';
import 'package:digital_bank/features/auth/domain/repositories/auth_repository.dart';
import 'package:digital_bank/features/auth/presentation/auth_state.dart';
import 'package:digital_bank/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/interfaces/i_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

class _FakeLogger implements ILogger {
  final List<String> messages = [];
  final List<Object?> technicalMessages = [];
  final List<StackTrace?> stackTraces = [];

  @override
  void info(String message, {String? technicalMessage}) {
    messages.add(message);
  }

  @override
  void error(
    String message, {
    Object? technicalMessage,
    StackTrace? stackTrace,
  }) {
    messages.add(message);
    technicalMessages.add(technicalMessage);
    stackTraces.add(stackTrace);
  }
}

ProviderContainer _containerWith(AuthRepository repository, {ILogger? logger}) {
  return ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
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
      final container = _containerWith(
        _FakeAuthRepository(
          result: const Success(AuthSession(accessToken: 'token-123')),
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

    test('AUTH-NOT-005 failure calls ILogger.error exactly once', () async {
      final logger = _FakeLogger();
      final container = _containerWith(
        _FakeAuthRepository(result: const Failure<AuthSession>(NetworkError())),
        logger: logger,
      );
      addTearDown(container.dispose);

      await container
          .read(authProvider.notifier)
          .login(email: 'customer@example.com', password: 'secret');

      expect(logger.messages, hasLength(1));
    });

    test('AUTH-NOT-006 logger payload contains no sensitive data', () async {
      final logger = _FakeLogger();
      final container = _containerWith(
        _FakeAuthRepository(
          result: const Failure<AuthSession>(
            NetworkError(technicalMessage: 'connection refused'),
          ),
        ),
        logger: logger,
      );
      addTearDown(container.dispose);

      await container
          .read(authProvider.notifier)
          .login(
            email: 'customer@example.com',
            password: 'super-secret-password',
          );

      final captured = [
        ...logger.messages,
        ...logger.technicalMessages.map((element) => element?.toString() ?? ''),
      ].join(' ');

      expect(captured, isNot(contains('super-secret-password')));
      expect(captured, isNot(contains('accessToken')));
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
  });
}
