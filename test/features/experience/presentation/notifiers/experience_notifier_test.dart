import 'package:digital_bank/core/services/observability/observability_provider.dart';
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

import '../../../../support/fake_observability.dart';

class _FakeExperienceRepository implements ExperienceRepository {
  _FakeExperienceRepository(this._result);

  final Result<ExperienceDefinition> _result;

  @override
  Future<Result<ExperienceDefinition>> fetchHomeExperience() async => _result;
}

ProviderContainer _containerWith(
  Result<ExperienceDefinition> result, {
  FakeObservability? observability,
}) {
  return ProviderContainer(
    overrides: [
      experienceRepositoryProvider.overrideWithValue(
        _FakeExperienceRepository(result),
      ),
      if (observability != null)
        observabilityProvider.overrideWithValue(observability),
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

  group('ExperienceNotifier observability', () {
    test(
      'reports experience_load_failed with status_code for ApiError',
      () async {
        final observability = FakeObservability();
        final container = _containerWith(
          const Failure(ApiError(statusCode: 500, technicalMessage: 'boom')),
          observability: observability,
        );
        addTearDown(container.dispose);

        await container.read(experienceProvider.notifier).load();

        expect(observability.events, hasLength(1));
        final event = observability.events.single;
        expect(event.name, 'experience_load_failed');
        expect(event.metadata['error_type'], 'ApiError');
        expect(event.metadata['status_code'], 500);
      },
    );

    test('reports NetworkError without status_code', () async {
      final observability = FakeObservability();
      final container = _containerWith(
        const Failure(NetworkError(technicalMessage: 'down')),
        observability: observability,
      );
      addTearDown(container.dispose);

      await container.read(experienceProvider.notifier).load();

      final event = observability.events.single;
      expect(event.name, 'experience_load_failed');
      expect(event.metadata['error_type'], 'NetworkError');
      expect(event.metadata.containsKey('status_code'), isFalse);
    });

    test('reports TimeoutError without status_code', () async {
      final observability = FakeObservability();
      final container = _containerWith(
        const Failure(TimeoutError(technicalMessage: 'slow')),
        observability: observability,
      );
      addTearDown(container.dispose);

      await container.read(experienceProvider.notifier).load();

      final event = observability.events.single;
      expect(event.metadata['error_type'], 'TimeoutError');
      expect(event.metadata.containsKey('status_code'), isFalse);
    });

    test('reports UnexpectedError without status_code', () async {
      final observability = FakeObservability();
      final container = _containerWith(
        const Failure(UnexpectedError(technicalMessage: 'bad schema')),
        observability: observability,
      );
      addTearDown(container.dispose);

      await container.read(experienceProvider.notifier).load();

      final event = observability.events.single;
      expect(event.metadata['error_type'], 'UnexpectedError');
      expect(event.metadata.containsKey('status_code'), isFalse);
    });

    test('does not report on success', () async {
      final observability = FakeObservability();
      final container = _containerWith(
        const Success(
          ExperienceDefinition(
            experience: 'account_home',
            version: 1,
            sections: [PromotionSection(title: 'Welcome')],
          ),
        ),
        observability: observability,
      );
      addTearDown(container.dispose);

      await container.read(experienceProvider.notifier).load();

      expect(observability.events, isEmpty);
    });
  });
}
