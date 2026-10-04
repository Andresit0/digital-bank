import 'package:digital_bank/core/services/logging/logging_providers.dart';
import 'package:digital_bank/core/services/observability/observability_provider.dart';
import 'package:digital_bank/features/accounts/di/accounts_providers.dart';
import 'package:digital_bank/features/accounts/domain/entities/account.dart';
import 'package:digital_bank/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:digital_bank/features/accounts/presentation/accounts_state.dart';
import 'package:digital_bank/features/accounts/presentation/notifiers/accounts_notifier.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/interfaces/i_logger.dart';
import 'package:digital_bank/shared/interfaces/i_observability.dart';
import 'package:digital_bank/shared/observability/observability_severity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fake_observability.dart';
import '../../../../support/observability_policy.dart';

class _FakeAccountsRepository implements AccountsRepository {
  _FakeAccountsRepository({this.result});

  final Result<List<Account>>? result;

  @override
  Future<Result<List<Account>>> fetchAccounts() async {
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
  AccountsRepository repository, {
  IObservability? observability,
  ILogger? logger,
}) {
  return ProviderContainer(
    overrides: [
      accountsRepositoryProvider.overrideWithValue(repository),
      if (observability != null)
        observabilityProvider.overrideWithValue(observability),
      if (logger != null) loggerProvider.overrideWithValue(logger),
    ],
  );
}

void main() {
  group('AccountsNotifier', () {
    test('ACC-NOT-001 starts in the initial state', () {
      final container = _containerWith(
        _FakeAccountsRepository(result: const Success<List<Account>>([])),
      );
      addTearDown(container.dispose);

      expect(container.read(accountsProvider), isA<AccountsInitial>());
    });

    test('ACC-NOT-002 success emits loading then loaded', () async {
      final container = _containerWith(
        _FakeAccountsRepository(
          result: const Success<List<Account>>([
            Account(
              id: 'acc-1',
              type: AccountType.savings,
              displayName: 'Savings Account',
              maskedNumber: '****1234',
              availableBalance: 1500.5,
            ),
          ]),
        ),
      );
      addTearDown(container.dispose);

      final future = container.read(accountsProvider.notifier).load();

      expect(container.read(accountsProvider), isA<AccountsLoading>());

      await future;

      final state = container.read(accountsProvider);
      expect(state, isA<AccountsLoaded>());
      expect((state as AccountsLoaded).accounts, hasLength(1));
    });

    test('ACC-NOT-003 empty result emits empty', () async {
      final container = _containerWith(
        _FakeAccountsRepository(result: const Success<List<Account>>([])),
      );
      addTearDown(container.dispose);

      await container.read(accountsProvider.notifier).load();

      expect(container.read(accountsProvider), isA<AccountsEmpty>());
    });

    test('ACC-NOT-004 failure emits failure with ApiError', () async {
      final container = _containerWith(
        _FakeAccountsRepository(
          result: const Failure<List<Account>>(ApiError(statusCode: 500)),
        ),
      );
      addTearDown(container.dispose);

      await container.read(accountsProvider.notifier).load();

      final state = container.read(accountsProvider);
      expect(state, isA<AccountsFailure>());
      final error = (state as AccountsFailure).error;
      expect(error, isA<ApiError>());
      expect((error as ApiError).statusCode, 500);
    });

    test(
      'ACC-NOT-005 failure reports exactly one event and does not use ILogger',
      () async {
        final observability = FakeObservability();
        final container = _containerWith(
          _FakeAccountsRepository(
            result: const Failure<List<Account>>(NetworkError()),
          ),
          observability: observability,
          logger: _ThrowingLogger(),
        );
        addTearDown(container.dispose);

        await container.read(accountsProvider.notifier).load();

        expect(observability.events, hasLength(1));
      },
    );

    test('ACC-NOT-006 captured accounts events respect the policy', () async {
      final observability = FakeObservability();
      final container = _containerWith(
        _FakeAccountsRepository(
          result: const Failure<List<Account>>(NetworkError()),
        ),
        observability: observability,
      );
      addTearDown(container.dispose);

      await container.read(accountsProvider.notifier).load();

      expectEventsRespectSensitiveDataPolicy(observability.events);
    });

    test('OBS-INT-ACC-001 server error reports accounts_load_failed', () async {
      final observability = FakeObservability();
      final container = _containerWith(
        _FakeAccountsRepository(
          result: const Failure<List<Account>>(ApiError(statusCode: 500)),
        ),
        observability: observability,
      );
      addTearDown(container.dispose);

      await container.read(accountsProvider.notifier).load();

      final event = observability.events.single;
      expect(event.name, 'accounts_load_failed');
      expect(event.severity, ObservabilitySeverity.warning);
      expect(event.metadata['errorType'], 'ApiError');
      expect(event.metadata['statusCode'], 500);
    });

    test(
      'OBS-INT-ACC-002 network failure reports accounts_load_failed',
      () async {
        final observability = FakeObservability();
        final container = _containerWith(
          _FakeAccountsRepository(
            result: const Failure<List<Account>>(NetworkError()),
          ),
          observability: observability,
        );
        addTearDown(container.dispose);

        await container.read(accountsProvider.notifier).load();

        final event = observability.events.single;
        expect(event.name, 'accounts_load_failed');
        expect(event.metadata['errorType'], 'NetworkError');
        expect(event.metadata.containsKey('statusCode'), isFalse);
      },
    );
  });
}
