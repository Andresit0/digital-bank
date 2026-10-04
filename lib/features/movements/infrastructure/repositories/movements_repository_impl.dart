import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/error/result_guard.dart';

import '../../domain/entities/movement.dart';
import '../../domain/repositories/movements_repository.dart';
import '../datasources/movements_remote_data_source.dart';
import '../models/movement_model.dart';

class MovementsRepositoryImpl implements MovementsRepository {
  MovementsRepositoryImpl(this._remoteDataSource);

  final MovementsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Movement>>> fetchMovements({required String accountId}) =>
      guard(() async {
        final models = await _remoteDataSource.fetchMovements(
          accountId: accountId,
        );
        return models.map(_toEntity).toList();
      });

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
