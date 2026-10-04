import 'package:digital_bank/features/accounts/di/accounts_providers.dart';
import 'package:digital_bank/features/accounts/domain/entities/account.dart';
import 'package:digital_bank/features/accounts/domain/errors/accounts_error.dart';
import 'package:digital_bank/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:digital_bank/features/accounts/presentation/accounts_state.dart';
import 'package:digital_bank/features/accounts/presentation/notifiers/accounts_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAccountsRepository implements AccountsRepository {
  _FakeAccountsRepository({this.accounts, this.error});

  final List<Account>? accounts;
  final Object? error;

  @override
  Future<List<Account>> fetchAccounts() async {
    if (error != null) {
      throw error!;
    }
    return accounts!;
  }
}

ProviderContainer _containerWith(AccountsRepository repository) {
  return ProviderContainer(
    overrides: [accountsRepositoryProvider.overrideWithValue(repository)],
  );
}

void main() {
  group('AccountsNotifier', () {
    test('starts in the initial state', () {
      final container = _containerWith(_FakeAccountsRepository(accounts: []));
      addTearDown(container.dispose);

      expect(container.read(accountsProvider), isA<AccountsInitial>());
    });

    test('emits loading then loaded on success', () async {
      final container = _containerWith(
        _FakeAccountsRepository(
          accounts: const [
            Account(
              id: 'acc-1',
              type: AccountType.savings,
              displayName: 'Savings Account',
              maskedNumber: '****1234',
              availableBalance: 1500.5,
            ),
          ],
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

    test('emits empty when the account list is empty', () async {
      final container = _containerWith(
        _FakeAccountsRepository(accounts: const []),
      );
      addTearDown(container.dispose);

      await container.read(accountsProvider.notifier).load();

      expect(container.read(accountsProvider), isA<AccountsEmpty>());
    });

    test('emits failure on error', () async {
      final container = _containerWith(
        _FakeAccountsRepository(error: AccountsError.network),
      );
      addTearDown(container.dispose);

      await container.read(accountsProvider.notifier).load();

      final state = container.read(accountsProvider);
      expect(state, isA<AccountsFailure>());
      expect((state as AccountsFailure).error, AccountsError.network);
    });
  });
}
