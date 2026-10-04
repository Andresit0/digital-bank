import 'package:digital_bank/features/movements/domain/entities/movement.dart';
import 'package:digital_bank/features/movements/infrastructure/datasources/movements_remote_data_source.dart';
import 'package:digital_bank/features/movements/infrastructure/models/movement_model.dart';
import 'package:digital_bank/features/movements/infrastructure/repositories/movements_repository_impl.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/exceptions/network_exception.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDataSource implements MovementsRemoteDataSource {
  _FakeDataSource({this.models, this.error});

  final List<MovementModel>? models;
  final Object? error;

  @override
  Future<List<MovementModel>> fetchMovements({
    required String accountId,
  }) async {
    if (error != null) {
      throw error!;
    }
    return models!;
  }
}

MovementModel _model({required String type, required double amount}) {
  return MovementModel(
    id: 'mov-1',
    accountId: 'acc-1',
    type: type,
    amount: amount,
    currency: 'USD',
    description: 'x',
    occurredAt: DateTime.utc(2026, 10, 1),
  );
}

void main() {
  group('MovementsRepositoryImpl', () {
    test(
      'MOV-REPO-001 success returns Success and maps credit/debit',
      () async {
        final repository = MovementsRepositoryImpl(
          _FakeDataSource(
            models: [
              _model(type: 'credit', amount: 500.0),
              _model(type: 'debit', amount: 125.5),
            ],
          ),
        );

        final result = await repository.fetchMovements(accountId: 'acc-1');

        expect(result, isA<Success<List<Movement>>>());
        final movements = (result as Success<List<Movement>>).data;
        expect(movements, hasLength(2));
        expect(movements.first.type, MovementType.credit);
        expect(movements.last.type, MovementType.debit);
        expect(movements.first.amount, 500.0);
      },
    );

    test('MOV-REPO-002 401 returns Failure(ApiError 401)', () async {
      final repository = MovementsRepositoryImpl(
        _FakeDataSource(
          error: const NetworkException(
            message: 'unauthorized',
            statusCode: 401,
          ),
        ),
      );

      final result = await repository.fetchMovements(accountId: 'acc-1');

      expect(result, isA<Failure<List<Movement>>>());
      final error = (result as Failure<List<Movement>>).error;
      expect(error, isA<ApiError>());
      expect((error as ApiError).statusCode, 401);
    });

    test('MOV-REPO-003 5xx returns Failure(ApiError 500)', () async {
      final repository = MovementsRepositoryImpl(
        _FakeDataSource(
          error: const NetworkException(
            message: 'server error',
            statusCode: 500,
          ),
        ),
      );

      final result = await repository.fetchMovements(accountId: 'acc-1');

      expect(result, isA<Failure<List<Movement>>>());
      final error = (result as Failure<List<Movement>>).error;
      expect(error, isA<ApiError>());
      expect((error as ApiError).statusCode, 500);
    });

    test(
      'MOV-REPO-004 transport failure returns Failure(NetworkError)',
      () async {
        final repository = MovementsRepositoryImpl(
          _FakeDataSource(error: const NetworkException(message: 'timeout')),
        );

        final result = await repository.fetchMovements(accountId: 'acc-1');

        expect(result, isA<Failure<List<Movement>>>());
        expect((result as Failure<List<Movement>>).error, isA<NetworkError>());
      },
    );

    test(
      'MOV-REPO-005 invalid payload (200) returns Failure(ApiError 200)',
      () async {
        final repository = MovementsRepositoryImpl(
          _FakeDataSource(
            error: const NetworkException(
              message: 'invalid movements payload',
              statusCode: 200,
            ),
          ),
        );

        final result = await repository.fetchMovements(accountId: 'acc-1');

        expect(result, isA<Failure<List<Movement>>>());
        final error = (result as Failure<List<Movement>>).error;
        expect(error, isA<ApiError>());
        expect((error as ApiError).statusCode, 200);
      },
    );
  });
}
