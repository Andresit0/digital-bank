import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/error/app_error.dart';
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
      failure: (error) => state = ExperienceFailure(_mapError(error)),
    );
  }

  ExperienceError _mapError(AppError error) {
    if (error is ApiError || error is NetworkError || error is TimeoutError) {
      return ExperienceError.network;
    }
    return ExperienceError.invalidConfiguration;
  }
}
