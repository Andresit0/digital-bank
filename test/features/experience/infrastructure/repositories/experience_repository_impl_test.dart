import 'package:digital_bank/features/experience/domain/entities/experience_definition.dart';
import 'package:digital_bank/features/experience/domain/entities/experience_section.dart';
import 'package:digital_bank/features/experience/infrastructure/datasources/experience_remote_data_source.dart';
import 'package:digital_bank/features/experience/infrastructure/models/experience_definition_model.dart';
import 'package:digital_bank/features/experience/infrastructure/models/experience_section_model.dart';
import 'package:digital_bank/features/experience/infrastructure/repositories/experience_repository_impl.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDataSource implements ExperienceRemoteDataSource {
  _FakeDataSource(this._result);

  final Result<ExperienceDefinitionModel> _result;

  @override
  Future<Result<ExperienceDefinitionModel>> fetchHomeExperience() async =>
      _result;
}

void main() {
  group('ExperienceRepositoryImpl', () {
    test('maps a model into the domain definition', () async {
      final repository = ExperienceRepositoryImpl(
        _FakeDataSource(
          const Success(
            ExperienceDefinitionModel(
              experience: 'account_home',
              version: 3,
              sections: [
                ExperienceSectionModel(
                  type: 'promotion',
                  title: 'Save more this month',
                ),
                ExperienceSectionModel(
                  type: 'quick_action',
                  label: 'View movements',
                  action: 'view_movements',
                ),
              ],
            ),
          ),
        ),
      );

      final result = await repository.fetchHomeExperience();

      result.when(
        success: (definition) {
          expect(definition, isA<ExperienceDefinition>());
          expect(definition.sections, hasLength(2));
          expect(definition.sections.first, isA<PromotionSection>());
          expect(definition.sections.last, isA<QuickActionSection>());
          expect(
            (definition.sections.last as QuickActionSection).action,
            QuickActionType.viewMovements,
          );
        },
        failure: (_) => fail('expected success'),
      );
    });

    test('preserves the AppError on failure', () async {
      final repository = ExperienceRepositoryImpl(
        _FakeDataSource(const Failure(NetworkError(technicalMessage: 'down'))),
      );

      final result = await repository.fetchHomeExperience();

      expect(result, isA<Failure<ExperienceDefinition>>());
      result.when(
        success: (_) => fail('expected failure'),
        failure: (error) => expect(error, isA<NetworkError>()),
      );
    });
  });
}
