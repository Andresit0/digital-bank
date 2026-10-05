import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/read.dart';

import '../entities/movement.dart';

abstract interface class MovementsRepository {
  Future<Result<Read<List<Movement>>>> fetchMovements({
    required String accountId,
  });
}
