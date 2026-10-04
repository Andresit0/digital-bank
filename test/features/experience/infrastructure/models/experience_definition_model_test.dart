import 'package:digital_bank/features/experience/infrastructure/models/experience_definition_model.dart';
import 'package:digital_bank/features/experience/infrastructure/models/experience_section_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExperienceDefinitionModel', () {
    test('parses a definition with a promotion and a quick action', () {
      final model = ExperienceDefinitionModel.fromJson({
        'experience': 'account_home',
        'version': 3,
        'sections': [
          {
            'type': 'promotion',
            'title': 'Save more this month',
            'description': 'Discover our latest promotion',
          },
          {
            'type': 'quick_action',
            'label': 'View movements',
            'action': 'view_movements',
          },
        ],
      });

      expect(model.experience, 'account_home');
      expect(model.version, 3);
      expect(model.sections, hasLength(2));
      expect(model.sections.first, isA<ExperienceSectionModel>());
    });

    test('parses an empty sections list', () {
      final model = ExperienceDefinitionModel.fromJson({
        'experience': 'account_home',
        'version': 1,
        'sections': <dynamic>[],
      });

      expect(model.sections, isEmpty);
    });

    test('rejects a definition missing the required fields', () {
      expect(
        () =>
            ExperienceDefinitionModel.fromJson({'experience': 'account_home'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('ignores an unsupported section type', () {
      final model = ExperienceDefinitionModel.fromJson({
        'experience': 'account_home',
        'version': 1,
        'sections': [
          {'type': 'unknown'},
          {'type': 'promotion', 'title': 'Welcome'},
        ],
      });

      expect(model.sections, hasLength(1));
      expect(model.sections.first.type, 'promotion');
    });

    test('rejects an unsupported quick action', () {
      expect(
        () => ExperienceDefinitionModel.fromJson({
          'experience': 'account_home',
          'version': 1,
          'sections': [
            {
              'type': 'quick_action',
              'label': 'Delete',
              'action': 'delete_account',
            },
          ],
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
