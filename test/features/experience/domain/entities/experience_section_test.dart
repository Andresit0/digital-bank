import 'package:digital_bank/features/experience/domain/entities/experience_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExperienceSection', () {
    test('PromotionSection exposes its fields', () {
      const section = PromotionSection(
        title: 'Save more this month',
        description: 'Discover our latest promotion',
      );

      expect(section, isA<ExperienceSection>());
      expect(section.title, 'Save more this month');
      expect(section.description, 'Discover our latest promotion');
    });

    test('PromotionSection description is optional', () {
      const section = PromotionSection(title: 'Title');

      expect(section.description, isNull);
    });

    test('QuickActionSection maps to a controlled QuickActionType', () {
      const section = QuickActionSection(
        label: 'View movements',
        action: QuickActionType.viewMovements,
      );

      expect(section, isA<ExperienceSection>());
      expect(section.label, 'View movements');
      expect(section.action, QuickActionType.viewMovements);
    });
  });
}
