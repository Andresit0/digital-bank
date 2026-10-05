import 'package:digital_bank/core/network/read_cache.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/error/result_guard.dart';
import 'package:digital_bank/shared/read.dart';

import '../../domain/entities/movement.dart';
import '../../domain/repositories/movements_repository.dart';
import '../datasources/movements_remote_data_source.dart';
import '../models/movement_model.dart';

class MovementsRepositoryImpl implements MovementsRepository {
  MovementsRepositoryImpl(this._remoteDataSource, this._readCache);

  final MovementsRemoteDataSource _remoteDataSource;
  final ReadCache _readCache;

  @override
  Future<Result<Read<List<Movement>>>> fetchMovements({
    required String accountId,
  }) async {
    final key = 'movements:$accountId';

    final result = await guard(() async {
      final models = await _remoteDataSource.fetchMovements(
        accountId: accountId,
      );
      return models.map(_toEntity).toList();
    });

    return result.when(
      success: (movements) {
        _readCache.put(key, movements);
        return Success<Read<List<Movement>>>(
          Read<List<Movement>>(movements, source: ReadSource.remote),
        );
      },
      failure: (error) {
        final cached = _readCache.get(key);
        if (cached is List<Movement>) {
          return Success<Read<List<Movement>>>(
            Read<List<Movement>>(cached, source: ReadSource.cache),
          );
        }
        return Failure<Read<List<Movement>>>(error);
      },
    );
  }

  Movement _toEntity(MovementModel model) {
    return Movement(
      id: model.id,
      accountId: model.accountId,
      type: model.type == 'credit' ? MovementType.credit : MovementType.debit,
      amount: model.amount,
      currency: model.currency,
      description: model.description,
      occurredAt: model.occurredAt,
    );
  }
}
