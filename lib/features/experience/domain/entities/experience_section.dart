import 'quick_action_type.dart';

export 'quick_action_type.dart';

sealed class ExperienceSection {
  const ExperienceSection();
}

class PromotionSection extends ExperienceSection {
  const PromotionSection({required this.title, this.description});

  final String title;
  final String? description;
}

class QuickActionSection extends ExperienceSection {
  const QuickActionSection({required this.label, required this.action});

  final String label;
  final QuickActionType action;
}
