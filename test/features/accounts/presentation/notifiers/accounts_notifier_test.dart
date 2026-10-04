import 'package:digital_bank/core/services/logging/logging_providers.dart';
import 'package:digital_bank/features/accounts/di/accounts_providers.dart';
import 'package:digital_bank/features/accounts/domain/entities/account.dart';
import 'package:digital_bank/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:digital_bank/features/accounts/presentation/accounts_state.dart';
import 'package:digital_bank/features/accounts/presentation/notifiers/accounts_notifier.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/interfaces/i_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAccountsRepository implements AccountsRepository {
  _FakeAccountsRepository({this.result});

  final Result<List<Account>>? result;

  @override
  Future<Result<List<Account>>> fetchAccounts() async {
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

ProviderContainer _containerWith(
  AccountsRepository repository, {
  ILogger? logger,
}) {
  return ProviderContainer(
    overrides: [
      accountsRepositoryProvider.overrideWithValue(repository),
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

    test('ACC-NOT-005 failure calls ILogger.error exactly once', () async {
      final logger = _FakeLogger();
      final container = _containerWith(
        _FakeAccountsRepository(
          result: const Failure<List<Account>>(NetworkError()),
        ),
        logger: logger,
      );
      addTearDown(container.dispose);

      await container.read(accountsProvider.notifier).load();

      expect(logger.messages, hasLength(1));
    });

    test('ACC-NOT-006 logger payload contains no sensitive data', () async {
      final logger = _FakeLogger();
      final container = _containerWith(
        _FakeAccountsRepository(
          result: const Failure<List<Account>>(
            NetworkError(technicalMessage: 'connection refused'),
          ),
        ),
        logger: logger,
      );
      addTearDown(container.dispose);

      await container.read(accountsProvider.notifier).load();

      final captured = [
        ...logger.messages,
        ...logger.technicalMessages.map((element) => element?.toString() ?? ''),
      ].join(' ');

      expect(captured, isNot(contains('****1234')));
      expect(captured, isNot(contains('1500')));
      expect(captured, isNot(contains('accessToken')));
    });
  });
}
