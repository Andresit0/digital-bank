import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/observability/observability_provider.dart';
import '../../../../shared/error/app_error.dart';
import '../../../../shared/observability/observability_event.dart';
import '../../../../shared/observability/observability_severity.dart';
import '../../di/experience_providers.dart';
import '../../domain/errors/experience_error.dart';
import '../experience_state.dart';

final experienceProvider =
    NotifierProvider<ExperienceNotifier, ExperienceState>(
      ExperienceNotifier.new,
    );

class ExperienceNotifier extends Notifier<ExperienceState> {
  @override
  ExperienceState build() => const ExperienceInitial();

  Future<void> load() async {
    if (state is ExperienceLoading) {
      return;
    }

    state = const ExperienceLoading();

    final result = await ref
        .read(experienceRepositoryProvider)
        .fetchHomeExperience();

    result.when(
      success: (definition) {
        state = definition.sections.isEmpty
            ? const ExperienceEmpty()
            : ExperienceLoaded(definition);
      },
      failure: (error) {
        ref.read(observabilityProvider).report(_loadFailedEvent(error));
        state = ExperienceFailure(_mapError(error));
      },
    );
  }

  ExperienceError _mapError(AppError error) {
    if (error is ApiError || error is NetworkError || error is TimeoutError) {
      return ExperienceError.network;
    }
    return ExperienceError.invalidConfiguration;
  }

  ObservabilityEvent _loadFailedEvent(AppError error) {
    final metadata = <String, Object?>{
      'error_type': error.runtimeType.toString(),
    };
    if (error is ApiError) {
      metadata['status_code'] = error.statusCode;
    }
    return ObservabilityEvent(
      name: 'experience_load_failed',
      severity: ObservabilitySeverity.warning,
      metadata: metadata,
    );
  }
}
