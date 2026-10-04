import 'package:digital_bank/features/accounts/domain/errors/accounts_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AccountsError', () {
    test('invalidCredentials is an AccountsError', () {
      expect(AccountsError.invalidCredentials, isA<AccountsError>());
    });

    test('network is an AccountsError', () {
      expect(AccountsError.network, isA<AccountsError>());
    });

    test('distinguishes the two variants', () {
      expect(
        AccountsError.invalidCredentials,
        isA<AccountsInvalidCredentials>(),
      );
      expect(AccountsError.network, isA<AccountsNetwork>());
    });
  });
}
