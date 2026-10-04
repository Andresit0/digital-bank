import 'package:digital_bank/shared/error/result.dart';

import '../entities/movement.dart';

abstract interface class MovementsRepository {
  Future<Result<List<Movement>>> fetchMovements({required String accountId});
}
