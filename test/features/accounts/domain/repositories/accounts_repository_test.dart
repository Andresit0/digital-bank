import 'package:digital_bank/features/accounts/domain/entities/account.dart';
import 'package:digital_bank/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/read.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAccountsRepository implements AccountsRepository {
  _FakeAccountsRepository(this._accounts);

  final List<Account> _accounts;

  @override
  Future<Result<Read<List<Account>>>> fetchAccounts() async =>
      Success(Read<List<Account>>(_accounts, source: ReadSource.remote));
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

      final result = await repository.fetchAccounts();

      expect(result, isA<Success<Read<List<Account>>>>());
      final read = (result as Success<Read<List<Account>>>).data;
      expect(read.data, hasLength(1));
      expect(read.data.first, isA<Account>());
    });

    test('fetchAccounts can return an empty list', () async {
      final repository = _FakeAccountsRepository(const []);

      final result = await repository.fetchAccounts();

      expect(result, isA<Success<Read<List<Account>>>>());
      final read = (result as Success<Read<List<Account>>>).data;
      expect(read.data, isEmpty);
    });
  });
}
