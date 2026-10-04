import 'package:digital_bank/features/experience/di/experience_providers.dart';
import 'package:digital_bank/features/experience/domain/entities/experience_definition.dart';
import 'package:digital_bank/features/experience/domain/entities/experience_section.dart';
import 'package:digital_bank/features/experience/domain/errors/experience_error.dart';
import 'package:digital_bank/features/experience/domain/repositories/experience_repository.dart';
import 'package:digital_bank/features/experience/presentation/experience_state.dart';
import 'package:digital_bank/features/experience/presentation/notifiers/experience_notifier.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeExperienceRepository implements ExperienceRepository {
  _FakeExperienceRepository(this._result);

  final Result<ExperienceDefinition> _result;

  @override
  Future<Result<ExperienceDefinition>> fetchHomeExperience() async => _result;
}

ProviderContainer _containerWith(Result<ExperienceDefinition> result) {
  return ProviderContainer(
    overrides: [
      experienceRepositoryProvider.overrideWithValue(
        _FakeExperienceRepository(result),
      ),
    ],
  );
}

void main() {
  group('ExperienceNotifier', () {
    test('starts in the initial state', () {
      final container = _containerWith(
        const Success(
          ExperienceDefinition(
            experience: 'account_home',
            version: 1,
            sections: [],
          ),
        ),
      );
      addTearDown(container.dispose);

      expect(container.read(experienceProvider), isA<ExperienceInitial>());
    });

    test('emits loading then loaded on success with sections', () async {
      final container = _containerWith(
        const Success(
          ExperienceDefinition(
            experience: 'account_home',
            version: 1,
            sections: [PromotionSection(title: 'Welcome')],
          ),
        ),
      );
      addTearDown(container.dispose);

      final future = container.read(experienceProvider.notifier).load();

      expect(container.read(experienceProvider), isA<ExperienceLoading>());

      await future;

      final state = container.read(experienceProvider);
      expect(state, isA<ExperienceLoaded>());
      expect((state as ExperienceLoaded).definition.sections, hasLength(1));
    });

    test('emits empty when the definition has no sections', () async {
      final container = _containerWith(
        const Success(
          ExperienceDefinition(
            experience: 'account_home',
            version: 1,
            sections: [],
          ),
        ),
      );
      addTearDown(container.dispose);

      await container.read(experienceProvider.notifier).load();

      expect(container.read(experienceProvider), isA<ExperienceEmpty>());
    });

    test('maps a network AppError to ExperienceError.network', () async {
      final container = _containerWith(
        const Failure(NetworkError(technicalMessage: 'down')),
      );
      addTearDown(container.dispose);

      await container.read(experienceProvider.notifier).load();

      final state = container.read(experienceProvider);
      expect(state, isA<ExperienceFailure>());
      expect((state as ExperienceFailure).error, ExperienceError.network);
    });

    test('maps an unexpected AppError to invalidConfiguration', () async {
      final container = _containerWith(
        const Failure(UnexpectedError(technicalMessage: 'bad schema')),
      );
      addTearDown(container.dispose);

      await container.read(experienceProvider.notifier).load();

      final state = container.read(experienceProvider);
      expect(state, isA<ExperienceFailure>());
      expect(
        (state as ExperienceFailure).error,
        ExperienceError.invalidConfiguration,
      );
    });
  });
}
