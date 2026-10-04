import 'package:digital_bank/features/accounts/domain/entities/account.dart';
import 'package:digital_bank/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAccountsRepository implements AccountsRepository {
  _FakeAccountsRepository(this._accounts);

  final List<Account> _accounts;

  @override
  Future<List<Account>> fetchAccounts() async => _accounts;
}

void main() {
  group('AccountsRepository contract', () {
    test('fetchAccounts returns a list of accounts', () async {
      final repository = _FakeAccountsRepository(const [
        Account(
          id: 'acc-1',
          type: AccountType.savings,
          displayName: 'Savings Account',
          maskedNumber: '****1234',
          availableBalance: 1500.50,
        ),
      ]);

      final accounts = await repository.fetchAccounts();

      expect(accounts, hasLength(1));
      expect(accounts.first, isA<Account>());
    });

    test('fetchAccounts can return an empty list', () async {
      final repository = _FakeAccountsRepository(const []);

      final accounts = await repository.fetchAccounts();

      expect(accounts, isEmpty);
    });
  });
}
