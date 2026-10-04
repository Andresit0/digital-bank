import 'package:digital_bank/features/accounts/infrastructure/models/account_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AccountModel', () {
    test('parses a savings account from JSON', () {
      final model = AccountModel.fromJson({
        'id': 'acc-1',
        'type': 'savings',
        'displayName': 'Savings Account',
        'maskedNumber': '****1234',
        'availableBalance': 1500.5,
      });

      expect(model.id, 'acc-1');
      expect(model.type, 'savings');
      expect(model.displayName, 'Savings Account');
      expect(model.maskedNumber, '****1234');
      expect(model.availableBalance, 1500.5);
    });

    test('parses a checking account from JSON', () {
      final model = AccountModel.fromJson({
        'id': 'acc-2',
        'type': 'checking',
        'displayName': 'Checking Account',
        'maskedNumber': '****5678',
        'availableBalance': 20.0,
      });

      expect(model.type, 'checking');
    });

    test('rejects an unknown account type', () {
      expect(
        () => AccountModel.fromJson({
          'id': 'acc-3',
          'type': 'unknown',
          'displayName': 'Mystery',
          'maskedNumber': '****0000',
          'availableBalance': 0.0,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a payload with missing mandatory fields', () {
      expect(
        () => AccountModel.fromJson({'id': 'acc-1'}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
