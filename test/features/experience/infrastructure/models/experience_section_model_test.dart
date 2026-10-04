import 'package:digital_bank/features/experience/infrastructure/models/experience_section_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExperienceSectionModel', () {
    test('parses a promotion section', () {
      final model = ExperienceSectionModel.fromJson({
        'type': 'promotion',
        'title': 'Save more this month',
        'description': 'Discover our latest promotion',
      });

      expect(model.type, 'promotion');
      expect(model.title, 'Save more this month');
      expect(model.description, 'Discover our latest promotion');
    });

    test('parses a quick action section', () {
      final model = ExperienceSectionModel.fromJson({
        'type': 'quick_action',
        'label': 'View movements',
        'action': 'view_movements',
      });

      expect(model.type, 'quick_action');
      expect(model.label, 'View movements');
      expect(model.action, 'view_movements');
    });

    test('rejects an unsupported section type', () {
      expect(
        () => ExperienceSectionModel.fromJson({'type': 'unknown'}),
        throwsA(isA<UnknownSectionTypeException>()),
      );
    });

    test('rejects an unsupported quick action', () {
      expect(
        () => ExperienceSectionModel.fromJson({
          'type': 'quick_action',
          'label': 'Delete',
          'action': 'delete_account',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a malformed promotion', () {
      expect(
        () => ExperienceSectionModel.fromJson({'type': 'promotion'}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
