sealed class ExperienceError {
  const ExperienceError();

  static const ExperienceError network = ExperienceNetwork();
  static const ExperienceError invalidConfiguration =
      ExperienceInvalidConfiguration();
}

final class ExperienceNetwork extends ExperienceError {
  const ExperienceNetwork();
}

final class ExperienceInvalidConfiguration extends ExperienceError {
  const ExperienceInvalidConfiguration();
}
