class UnknownSectionTypeException implements Exception {
  const UnknownSectionTypeException(this.type);

  final String type;
}

class ExperienceSectionModel {
  const ExperienceSectionModel({
    required this.type,
    this.title,
    this.description,
    this.label,
    this.action,
  });

  factory ExperienceSectionModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type is! String) {
      throw const FormatException('section type must be a string');
    }

    switch (type) {
      case 'promotion':
        final title = json['title'];
        if (title is! String) {
          throw const FormatException('promotion title must be a string');
        }
        final description = json['description'];
        if (description != null && description is! String) {
          throw const FormatException('promotion description must be a string');
        }
        return ExperienceSectionModel(
          type: type,
          title: title,
          description: description as String?,
        );
      case 'quick_action':
        final label = json['label'];
        if (label is! String) {
          throw const FormatException('quick action label must be a string');
        }
        final action = json['action'];
        if (action is! String ||
            (action != 'view_movements' && action != 'view_accounts')) {
          throw const FormatException('unsupported quick action');
        }
        return ExperienceSectionModel(type: type, label: label, action: action);
      default:
        throw UnknownSectionTypeException(type);
    }
  }

  final String type;
  final String? title;
  final String? description;
  final String? label;
  final String? action;
}
