import 'package:digital_bank/features/experience/domain/errors/experience_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExperienceError', () {
    test('network is an ExperienceError', () {
      expect(ExperienceError.network, isA<ExperienceError>());
    });

    test('invalidConfiguration is an ExperienceError', () {
      expect(ExperienceError.invalidConfiguration, isA<ExperienceError>());
    });

    test('distinguishes the two variants', () {
      expect(ExperienceError.network, isA<ExperienceNetwork>());
      expect(
        ExperienceError.invalidConfiguration,
        isA<ExperienceInvalidConfiguration>(),
      );
    });
  });
}
