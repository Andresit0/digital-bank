import 'experience_section_model.dart';

class ExperienceDefinitionModel {
  const ExperienceDefinitionModel({
    required this.experience,
    required this.version,
    required this.sections,
  });

  factory ExperienceDefinitionModel.fromJson(Map<String, dynamic> json) {
    final experience = json['experience'];
    if (experience is! String) {
      throw const FormatException('experience must be a string');
    }

    final version = json['version'];
    if (version is! int) {
      throw const FormatException('version must be an integer');
    }

    final rawSections = json['sections'];
    if (rawSections is! List) {
      throw const FormatException('sections must be a list');
    }

    final sections = <ExperienceSectionModel>[];
    for (final item in rawSections) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('section must be an object');
      }
      try {
        sections.add(ExperienceSectionModel.fromJson(item));
      } on UnknownSectionTypeException {
        continue;
      }
    }

    return ExperienceDefinitionModel(
      experience: experience,
      version: version,
      sections: sections,
    );
  }

  final String experience;
  final int version;
  final List<ExperienceSectionModel> sections;
}
