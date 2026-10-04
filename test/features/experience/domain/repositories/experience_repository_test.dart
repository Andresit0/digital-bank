import 'package:digital_bank/features/experience/domain/entities/experience_definition.dart';
import 'package:digital_bank/features/experience/domain/repositories/experience_repository.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeExperienceRepository implements ExperienceRepository {
  _FakeExperienceRepository(this._result);

  final Result<ExperienceDefinition> _result;

  @override
  Future<Result<ExperienceDefinition>> fetchHomeExperience() async => _result;
}

void main() {
  group('ExperienceRepository contract', () {
    test('fetchHomeExperience returns a Result with a definition', () async {
      const definition = ExperienceDefinition(
        experience: 'account_home',
        version: 1,
        sections: [],
      );
      final repository = _FakeExperienceRepository(const Success(definition));

      final result = await repository.fetchHomeExperience();

      expect(result, isA<Success<ExperienceDefinition>>());
      result.when(
        success: (data) => expect(data.experience, 'account_home'),
        failure: (_) => fail('expected success'),
      );
    });
  });
}
