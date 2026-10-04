import 'experience_section.dart';

class ExperienceDefinition {
  const ExperienceDefinition({
    required this.experience,
    required this.version,
    required this.sections,
  });

  final String experience;
  final int version;
  final List<ExperienceSection> sections;
}
