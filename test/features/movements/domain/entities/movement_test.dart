import 'package:digital_bank/features/movements/domain/entities/movement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Movement', () {
    final occurredAt = DateTime.utc(2026, 10, 4, 12);
    final movement = Movement(
      id: 'mov-1',
      accountId: 'acc-1',
      type: MovementType.debit,
      amount: 125.50,
      currency: 'USD',
      description: 'Card purchase',
      occurredAt: occurredAt,
    );

    test('UNIT-MOV-001 exposes its fields', () {
      expect(movement.id, 'mov-1');
      expect(movement.accountId, 'acc-1');
      expect(movement.type, MovementType.debit);
      expect(movement.amount, 125.50);
      expect(movement.currency, 'USD');
      expect(movement.description, 'Card purchase');
      expect(movement.occurredAt, occurredAt);
    });

    test('UNIT-MOV-001 supports value equality', () {
      final same = Movement(
        id: 'mov-1',
        accountId: 'acc-1',
        type: MovementType.debit,
        amount: 125.50,
        currency: 'USD',
        description: 'Card purchase',
        occurredAt: occurredAt,
      );

      expect(movement, equals(same));
      expect(movement.hashCode, same.hashCode);
    });

    test('UNIT-MOV-001 is not equal when a field differs', () {
      final other = Movement(
        id: 'mov-1',
        accountId: 'acc-1',
        type: MovementType.credit,
        amount: 125.50,
        currency: 'USD',
        description: 'Card purchase',
        occurredAt: occurredAt,
      );

      expect(movement, isNot(equals(other)));
    });
  });

  group('MovementType', () {
    test('UNIT-MOV-002 exposes credit and debit', () {
      expect(MovementType.values, [MovementType.credit, MovementType.debit]);
    });
  });
}
