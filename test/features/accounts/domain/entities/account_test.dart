import 'package:digital_bank/features/accounts/domain/entities/account.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Account', () {
    const account = Account(
      id: 'acc-1',
      type: AccountType.savings,
      displayName: 'Savings Account',
      maskedNumber: '****1234',
      availableBalance: 1500.50,
    );

    test('exposes its fields', () {
      expect(account.id, 'acc-1');
      expect(account.type, AccountType.savings);
      expect(account.displayName, 'Savings Account');
      expect(account.maskedNumber, '****1234');
      expect(account.availableBalance, 1500.50);
    });

    test('supports value equality', () {
      const same = Account(
        id: 'acc-1',
        type: AccountType.savings,
        displayName: 'Savings Account',
        maskedNumber: '****1234',
        availableBalance: 1500.50,
      );

      expect(account, equals(same));
      expect(account.hashCode, same.hashCode);
    });

    test('is not equal when a field differs', () {
      const other = Account(
        id: 'acc-1',
        type: AccountType.checking,
        displayName: 'Savings Account',
        maskedNumber: '****1234',
        availableBalance: 1500.50,
      );

      expect(account, isNot(equals(other)));
    });
  });

  group('AccountType', () {
    test('exposes savings and checking', () {
      expect(AccountType.values, [AccountType.savings, AccountType.checking]);
    });
  });
}
