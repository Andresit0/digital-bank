import 'package:digital_bank/features/movements/infrastructure/models/movement_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MovementModel', () {
    test('maps JSON to model fields and parses occurredAt', () {
      final model = MovementModel.fromJson({
        'id': 'mov-1',
        'accountId': 'acc-1',
        'type': 'credit',
        'amount': 500,
        'currency': 'USD',
        'description': 'Salary',
        'occurredAt': '2026-10-01T09:30:00.000Z',
      });

      expect(model.id, 'mov-1');
      expect(model.accountId, 'acc-1');
      expect(model.type, 'credit');
      expect(model.amount, 500.0);
      expect(model.currency, 'USD');
      expect(model.description, 'Salary');
      expect(model.occurredAt, DateTime.parse('2026-10-01T09:30:00.000Z'));
    });

    test('converts a num amount to double', () {
      final model = MovementModel.fromJson({
        'id': 'mov-2',
        'accountId': 'acc-1',
        'type': 'debit',
        'amount': 1500.5,
        'currency': 'USD',
        'description': 'Card purchase',
        'occurredAt': '2026-10-02T12:00:00.000Z',
      });

      expect(model.amount, isA<double>());
      expect(model.amount, 1500.5);
    });

    test('throws FormatException for an unknown type', () {
      expect(
        () => MovementModel.fromJson({
          'id': 'mov-3',
          'accountId': 'acc-1',
          'type': 'unknown',
          'amount': 10.0,
          'currency': 'USD',
          'description': 'x',
          'occurredAt': '2026-10-02T12:00:00.000Z',
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
