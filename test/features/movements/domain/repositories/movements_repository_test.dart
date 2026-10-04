import 'package:digital_bank/features/movements/domain/entities/movement.dart';
import 'package:digital_bank/features/movements/domain/repositories/movements_repository.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMovementsRepository implements MovementsRepository {
  _FakeMovementsRepository(this._movements);

  final List<Movement> _movements;
  String? lastAccountId;

  @override
  Future<Result<List<Movement>>> fetchMovements({
    required String accountId,
  }) async {
    lastAccountId = accountId;
    return Success(_movements);
  }
}

void main() {
  group('MovementsRepository contract', () {
    test('fetchMovements accepts an accountId and returns movements', () async {
      final repository = _FakeMovementsRepository([
        Movement(
          id: 'mov-1',
          accountId: 'acc-1',
          type: MovementType.credit,
          amount: 500.00,
          currency: 'USD',
          description: 'Salary',
          occurredAt: DateTime.utc(2026, 10, 1),
        ),
      ]);

      final result = await repository.fetchMovements(accountId: 'acc-1');

      expect(repository.lastAccountId, 'acc-1');
      expect(result, isA<Success<List<Movement>>>());
      expect((result as Success<List<Movement>>).data, hasLength(1));
      expect(result.data.first, isA<Movement>());
    });

    test('fetchMovements can return an empty list', () async {
      final repository = _FakeMovementsRepository(const []);

      final result = await repository.fetchMovements(accountId: 'acc-1');

      expect(result, isA<Success<List<Movement>>>());
      expect((result as Success<List<Movement>>).data, isEmpty);
    });
  });
}
