import 'package:digital_bank/features/movements/di/movements_providers.dart';
import 'package:digital_bank/features/movements/domain/entities/movement.dart';
import 'package:digital_bank/features/movements/domain/repositories/movements_repository.dart';
import 'package:digital_bank/features/movements/presentation/movements_state.dart';
import 'package:digital_bank/features/movements/presentation/notifiers/movements_notifier.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMovementsRepository implements MovementsRepository {
  _FakeMovementsRepository({this.result});

  final Result<List<Movement>>? result;
  String? lastAccountId;

  @override
  Future<Result<List<Movement>>> fetchMovements({
    required String accountId,
  }) async {
    lastAccountId = accountId;
    return result!;
  }
}

Movement _movement({required String type}) {
  return Movement(
    id: 'mov-1',
    accountId: 'acc-1',
    type: type == 'credit' ? MovementType.credit : MovementType.debit,
    amount: 500.0,
    currency: 'USD',
    description: 'Salary',
    occurredAt: DateTime.utc(2026, 10, 1),
  );
}

ProviderContainer _containerWith(MovementsRepository repository) {
  return ProviderContainer(
    overrides: [movementsRepositoryProvider.overrideWithValue(repository)],
  );
}

void main() {
  group('MovementsNotifier', () {
    test('starts in the initial state', () {
      final container = _containerWith(
        _FakeMovementsRepository(result: const Success<List<Movement>>([])),
      );
      addTearDown(container.dispose);

      expect(container.read(movementsProvider), isA<MovementsInitial>());
    });

    test('load requires an accountId and emits loading then loaded', () async {
      final repository = _FakeMovementsRepository(
        result: Success<List<Movement>>([_movement(type: 'credit')]),
      );
      final container = _containerWith(repository);
      addTearDown(container.dispose);

      final future = container
          .read(movementsProvider.notifier)
          .load(accountId: 'acc-1');

      expect(container.read(movementsProvider), isA<MovementsLoading>());

      await future;

      expect(repository.lastAccountId, 'acc-1');
      final state = container.read(movementsProvider);
      expect(state, isA<MovementsLoaded>());
      expect((state as MovementsLoaded).movements, hasLength(1));
    });

    test('empty result emits empty', () async {
      final container = _containerWith(
        _FakeMovementsRepository(result: const Success<List<Movement>>([])),
      );
      addTearDown(container.dispose);

      await container.read(movementsProvider.notifier).load(accountId: 'acc-1');

      expect(container.read(movementsProvider), isA<MovementsEmpty>());
    });

    test('failure emits failure with the mapped AppError', () async {
      final container = _containerWith(
        _FakeMovementsRepository(
          result: const Failure<List<Movement>>(ApiError(statusCode: 500)),
        ),
      );
      addTearDown(container.dispose);

      await container.read(movementsProvider.notifier).load(accountId: 'acc-1');

      final state = container.read(movementsProvider);
      expect(state, isA<MovementsFailure>());
      expect((state as MovementsFailure).error, isA<ApiError>());
    });
  });
}
