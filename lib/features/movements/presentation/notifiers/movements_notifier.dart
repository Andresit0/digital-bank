import 'package:digital_bank/core/services/observability/observability_provider.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/observability/observability_event.dart';
import 'package:digital_bank/shared/observability/observability_severity.dart';
import 'package:digital_bank/shared/read.dart';
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
      success: (read) {
        if (read.source == ReadSource.cache) {
          ref.read(observabilityProvider).report(_staleServedEvent());
          state = MovementsStale(read.data);
          return;
        }

        state = read.data.isEmpty
            ? const MovementsEmpty()
            : MovementsLoaded(read.data);
      },
      failure: (error) {
        ref.read(observabilityProvider).report(_loadFailedEvent(error));
        state = MovementsFailure(error);
      },
    );
  }

  ObservabilityEvent _loadFailedEvent(AppError error) {
    final metadata = <String, Object?>{
      'errorType': error.runtimeType.toString(),
    };
    if (error is ApiError && error.statusCode != null) {
      metadata['statusCode'] = error.statusCode;
    }
    return ObservabilityEvent(
      name: 'movements_load_failed',
      severity: ObservabilitySeverity.warning,
      metadata: metadata,
    );
  }

  ObservabilityEvent _staleServedEvent() {
    return const ObservabilityEvent(
      name: 'movements_stale_served',
      severity: ObservabilitySeverity.warning,
      metadata: {'source': 'cache'},
    );
  }
}
