import '../domain/entities/experience_definition.dart';
import '../domain/errors/experience_error.dart';

sealed class ExperienceState {
  const ExperienceState();
}

final class ExperienceInitial extends ExperienceState {
  const ExperienceInitial();
}

final class ExperienceLoading extends ExperienceState {
  const ExperienceLoading();
}

final class ExperienceLoaded extends ExperienceState {
  const ExperienceLoaded(this.definition);

  final ExperienceDefinition definition;
}

final class ExperienceEmpty extends ExperienceState {
  const ExperienceEmpty();
}

final class ExperienceFailure extends ExperienceState {
  const ExperienceFailure(this.error);

  final ExperienceError error;
}
