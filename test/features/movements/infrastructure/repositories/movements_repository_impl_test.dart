import 'package:digital_bank/core/network/read_cache.dart';
import 'package:digital_bank/features/movements/domain/entities/movement.dart';
import 'package:digital_bank/features/movements/infrastructure/datasources/movements_remote_data_source.dart';
import 'package:digital_bank/features/movements/infrastructure/models/movement_model.dart';
import 'package:digital_bank/features/movements/infrastructure/repositories/movements_repository_impl.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/exceptions/network_exception.dart';
import 'package:digital_bank/shared/read.dart';
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

Movement _movement({String accountId = 'acc-1'}) {
  return Movement(
    id: 'mov-1',
    accountId: accountId,
    type: MovementType.credit,
    amount: 500.0,
    currency: 'USD',
    description: 'Salary',
    occurredAt: DateTime.utc(2026, 10, 1),
  );
}

void main() {
  group('MovementsRepositoryImpl', () {
    test('MOV-REPO-001 remote success returns ReadSource.remote', () async {
      final repository = MovementsRepositoryImpl(
        _FakeDataSource(
          models: [
            _model(type: 'credit', amount: 500.0),
            _model(type: 'debit', amount: 125.5),
          ],
        ),
        ReadCache(),
      );

      final result = await repository.fetchMovements(accountId: 'acc-1');

      expect(result, isA<Success<Read<List<Movement>>>>());
      final read = (result as Success<Read<List<Movement>>>).data;
      expect(read.source, ReadSource.remote);
      expect(read.data, hasLength(2));
      expect(read.data.first.type, MovementType.credit);
      expect(read.data.last.type, MovementType.debit);
      expect(read.data.first.amount, 500.0);
    });

    test('MOV-REPO-002 remote success caches under movements:<accountId>', () async {
      final readCache = ReadCache();
      final repository = MovementsRepositoryImpl(
        _FakeDataSource(
          models: [
            _model(type: 'credit', amount: 500.0),
            _model(type: 'debit', amount: 125.5),
          ],
        ),
        readCache,
      );

      await repository.fetchMovements(accountId: 'acc-1');

      final cached = readCache.get('movements:acc-1');
      expect(cached, isA<List<Movement>>());
      expect(cached as List<Movement>, hasLength(2));
    });

    test(
      'MOV-REPO-003 failed remote with matching cache returns ReadSource.cache',
      () async {
        final readCache = ReadCache()
          ..put('movements:acc-1', [_movement()]);
        final repository = MovementsRepositoryImpl(
          _FakeDataSource(error: const NetworkException(message: 'timeout')),
          readCache,
        );

        final result = await repository.fetchMovements(accountId: 'acc-1');

        expect(result, isA<Success<Read<List<Movement>>>>());
        final read = (result as Success<Read<List<Movement>>>).data;
        expect(read.source, ReadSource.cache);
        expect(read.data, hasLength(1));
        expect(read.data.first.accountId, 'acc-1');
      },
    );

    test(
      'MOV-REPO-004 failed remote without cache preserves original Failure',
      () async {
        final repository = MovementsRepositoryImpl(
          _FakeDataSource(error: const NetworkException(message: 'timeout')),
          ReadCache(),
        );

        final result = await repository.fetchMovements(accountId: 'acc-1');

        expect(result, isA<Failure<Read<List<Movement>>>>());
        expect(
          (result as Failure<Read<List<Movement>>>).error,
          isA<NetworkError>(),
        );
      },
    );

    test('MOV-REPO-005 failed remote never writes to cache', () async {
      final readCache = ReadCache();
      final repository = MovementsRepositoryImpl(
        _FakeDataSource(error: const NetworkException(message: 'timeout')),
        readCache,
      );

      await repository.fetchMovements(accountId: 'acc-1');

      expect(readCache.get('movements:acc-1'), isNull);
    });

    test('MOV-REPO-006 cache is isolated by accountId', () async {
      final readCache = ReadCache()
        ..put('movements:acc-a', [_movement(accountId: 'acc-a')]);
      final repository = MovementsRepositoryImpl(
        _FakeDataSource(error: const NetworkException(message: 'timeout')),
        readCache,
      );

      final forB = await repository.fetchMovements(accountId: 'acc-b');

      expect(forB, isA<Failure<Read<List<Movement>>>>());

      final forA = await repository.fetchMovements(accountId: 'acc-a');

      expect(forA, isA<Success<Read<List<Movement>>>>());
      expect(
        (forA as Success<Read<List<Movement>>>).data.source,
        ReadSource.cache,
      );
    });

    test('MOV-REPO-007 401 returns Failure(ApiError 401)', () async {
      final repository = MovementsRepositoryImpl(
        _FakeDataSource(
          error: const NetworkException(
            message: 'unauthorized',
            statusCode: 401,
          ),
        ),
        ReadCache(),
      );

      final result = await repository.fetchMovements(accountId: 'acc-1');

      expect(result, isA<Failure<Read<List<Movement>>>>());
      final error = (result as Failure<Read<List<Movement>>>).error;
      expect(error, isA<ApiError>());
      expect((error as ApiError).statusCode, 401);
    });

    test('MOV-REPO-008 5xx returns Failure(ApiError 500)', () async {
      final repository = MovementsRepositoryImpl(
        _FakeDataSource(
          error: const NetworkException(
            message: 'server error',
            statusCode: 500,
          ),
        ),
        ReadCache(),
      );

      final result = await repository.fetchMovements(accountId: 'acc-1');

      expect(result, isA<Failure<Read<List<Movement>>>>());
      final error = (result as Failure<Read<List<Movement>>>).error;
      expect(error, isA<ApiError>());
      expect((error as ApiError).statusCode, 500);
    });

    test(
      'MOV-REPO-009 transport failure returns Failure(NetworkError)',
      () async {
        final repository = MovementsRepositoryImpl(
          _FakeDataSource(error: const NetworkException(message: 'timeout')),
          ReadCache(),
        );

        final result = await repository.fetchMovements(accountId: 'acc-1');

        expect(result, isA<Failure<Read<List<Movement>>>>());
        expect(
          (result as Failure<Read<List<Movement>>>).error,
          isA<NetworkError>(),
        );
      },
    );

    test(
      'MOV-REPO-010 invalid payload (200) returns Failure(ApiError 200)',
      () async {
        final repository = MovementsRepositoryImpl(
          _FakeDataSource(
            error: const NetworkException(
              message: 'invalid movements payload',
              statusCode: 200,
            ),
          ),
          ReadCache(),
        );

        final result = await repository.fetchMovements(accountId: 'acc-1');

        expect(result, isA<Failure<Read<List<Movement>>>>());
        final error = (result as Failure<Read<List<Movement>>>).error;
        expect(error, isA<ApiError>());
        expect((error as ApiError).statusCode, 200);
      },
    );
  });
}
