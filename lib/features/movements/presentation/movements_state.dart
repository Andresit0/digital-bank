import 'package:digital_bank/shared/error/app_error.dart';

import '../domain/entities/movement.dart';

sealed class MovementsState {
  const MovementsState();
}

final class MovementsInitial extends MovementsState {
  const MovementsInitial();
}

final class MovementsLoading extends MovementsState {
  const MovementsLoading();
}

final class MovementsLoaded extends MovementsState {
  const MovementsLoaded(this.movements);

  final List<Movement> movements;
}

final class MovementsStale extends MovementsState {
  const MovementsStale(this.movements);

  final List<Movement> movements;
}

final class MovementsEmpty extends MovementsState {
  const MovementsEmpty();
}

final class MovementsFailure extends MovementsState {
  const MovementsFailure(this.error);

  final AppError error;
}
