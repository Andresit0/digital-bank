import 'package:digital_bank/features/experience/domain/entities/experience_definition.dart';
import 'package:digital_bank/features/experience/domain/entities/experience_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExperienceDefinition', () {
    test('exposes its fields and sections', () {
      const definition = ExperienceDefinition(
        experience: 'account_home',
        version: 3,
        sections: [PromotionSection(title: 'Save more this month')],
      );

      expect(definition.experience, 'account_home');
      expect(definition.version, 3);
      expect(definition.sections, hasLength(1));
      expect(definition.sections.first, isA<PromotionSection>());
    });

    test('can be constructed with no sections', () {
      const definition = ExperienceDefinition(
        experience: 'account_home',
        version: 1,
        sections: [],
      );

      expect(definition.sections, isEmpty);
    });
  });
}
