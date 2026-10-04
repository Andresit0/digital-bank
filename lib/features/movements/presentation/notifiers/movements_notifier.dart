import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/movements_providers.dart';
import '../movements_state.dart';

final movementsProvider = NotifierProvider<MovementsNotifier, MovementsState>(
  MovementsNotifier.new,
);

class MovementsNotifier extends Notifier<MovementsState> {
  @override
  MovementsState build() => const MovementsInitial();

  Future<void> load({required String accountId}) async {
    if (state is MovementsLoading) {
      return;
    }

    state = const MovementsLoading();

    final result = await ref
        .read(movementsRepositoryProvider)
        .fetchMovements(accountId: accountId);

    result.when(
      success: (movements) {
        state = movements.isEmpty
            ? const MovementsEmpty()
            : MovementsLoaded(movements);
      },
      failure: (error) {
        state = MovementsFailure(error);
      },
    );
  }
}
