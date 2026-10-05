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
  _FakeExperienceRepository({this.result, this.sequence});

  final Result<ExperienceDefinition>? result;
  final List<Result<ExperienceDefinition>>? sequence;
  int calls = 0;

  @override
  Future<Result<ExperienceDefinition>> fetchHomeExperience() async {
    final queued = sequence;
    if (queued != null && queued.isNotEmpty) {
      final index = calls < queued.length ? calls : queued.length - 1;
      calls++;
      return queued[index];
    }
    return result!;
  }
}

const Result<ExperienceDefinition> _loaded = Success<ExperienceDefinition>(
  ExperienceDefinition(
    experience: 'account_home',
    version: 1,
    sections: [PromotionSection(title: 'Welcome')],
  ),
);

const Result<ExperienceDefinition> _empty = Success<ExperienceDefinition>(
  ExperienceDefinition(
    experience: 'account_home',
    version: 1,
    sections: [],
  ),
);

const Result<ExperienceDefinition> _networkFailure =
    Failure<ExperienceDefinition>(NetworkError(technicalMessage: 'down'));

const Result<ExperienceDefinition> _invalidConfiguration =
    Failure<ExperienceDefinition>(
      UnexpectedError(technicalMessage: 'bad schema'),
    );

ProviderContainer _containerWith(
  ExperienceRepository repository, {
  FakeObservability? observability,
}) {
  return ProviderContainer(
    overrides: [
      experienceRepositoryProvider.overrideWithValue(repository),
      if (observability != null)
        observabilityProvider.overrideWithValue(observability),
    ],
  );
}

void main() {
  group('ExperienceNotifier', () {
    test('starts in the initial state', () {
      final container = _containerWith(
        _FakeExperienceRepository(result: _empty),
      );
      addTearDown(container.dispose);

      expect(container.read(experienceProvider), isA<ExperienceInitial>());
    });

    test('emits loading then loaded on success with sections', () async {
      final container = _containerWith(
        _FakeExperienceRepository(result: _loaded),
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
        _FakeExperienceRepository(result: _empty),
      );
      addTearDown(container.dispose);

      await container.read(experienceProvider.notifier).load();

      expect(container.read(experienceProvider), isA<ExperienceEmpty>());
    });

    test('EXP-NOT-005 network failure emits ExperienceDegraded', () async {
      final container = _containerWith(
        _FakeExperienceRepository(result: _networkFailure),
      );
      addTearDown(container.dispose);

      await container.read(experienceProvider.notifier).load();

      final state = container.read(experienceProvider);
      expect(state, isA<ExperienceDegraded>());
      expect((state as ExperienceDegraded).error, ExperienceError.network);
    });

    test(
      'EXP-NOT-006 invalid configuration emits ExperienceDegraded',
      () async {
        final container = _containerWith(
          _FakeExperienceRepository(result: _invalidConfiguration),
        );
        addTearDown(container.dispose);

        await container.read(experienceProvider.notifier).load();

        final state = container.read(experienceProvider);
        expect(state, isA<ExperienceDegraded>());
        expect(
          (state as ExperienceDegraded).error,
          ExperienceError.invalidConfiguration,
        );
      },
    );

    test('EXP-NOT-007 degraded -> retry -> loading -> recovery', () async {
      final repository = _FakeExperienceRepository(
        sequence: [_networkFailure, _loaded],
      );
      final container = _containerWith(repository);
      addTearDown(container.dispose);

      final notifier = container.read(experienceProvider.notifier);

      await notifier.load();
      expect(container.read(experienceProvider), isA<ExperienceDegraded>());

      final future = notifier.load();
      expect(container.read(experienceProvider), isA<ExperienceLoading>());

      await future;
      expect(container.read(experienceProvider), isA<ExperienceLoaded>());
      expect(repository.calls, 2);
    });

    test('EXP-NOT-008 degraded retry failure stays degraded', () async {
      final repository = _FakeExperienceRepository(
        sequence: [_networkFailure, _networkFailure],
      );
      final container = _containerWith(repository);
      addTearDown(container.dispose);

      final notifier = container.read(experienceProvider.notifier);

      await notifier.load();
      expect(container.read(experienceProvider), isA<ExperienceDegraded>());

      final future = notifier.load();
      expect(container.read(experienceProvider), isA<ExperienceLoading>());

      await future;
      expect(container.read(experienceProvider), isA<ExperienceDegraded>());
      expect(repository.calls, 2);
    });
  });

  group('ExperienceNotifier observability', () {
    test('OBS-EXP-003 degradation reports experience_degraded for ApiError', () async {
      final observability = FakeObservability();
      final container = _containerWith(
        _FakeExperienceRepository(
          result: const Failure<ExperienceDefinition>(
            ApiError(statusCode: 500, technicalMessage: 'boom'),
          ),
        ),
        observability: observability,
      );
      addTearDown(container.dispose);

      await container.read(experienceProvider.notifier).load();

      expect(observability.events, hasLength(1));
      final event = observability.events.single;
      expect(event.name, 'experience_degraded');
      expect(event.metadata['error_type'], 'ApiError');
      expect(event.metadata['status_code'], 500);
    });

    test('reports NetworkError without status_code', () async {
      final observability = FakeObservability();
      final container = _containerWith(
        _FakeExperienceRepository(result: _networkFailure),
        observability: observability,
      );
      addTearDown(container.dispose);

      await container.read(experienceProvider.notifier).load();

      final event = observability.events.single;
      expect(event.name, 'experience_degraded');
      expect(event.metadata['error_type'], 'NetworkError');
      expect(event.metadata.containsKey('status_code'), isFalse);
    });

    test('reports TimeoutError without status_code', () async {
      final observability = FakeObservability();
      final container = _containerWith(
        _FakeExperienceRepository(
          result: const Failure<ExperienceDefinition>(
            TimeoutError(technicalMessage: 'slow'),
          ),
        ),
        observability: observability,
      );
      addTearDown(container.dispose);

      await container.read(experienceProvider.notifier).load();

      final event = observability.events.single;
      expect(event.name, 'experience_degraded');
      expect(event.metadata['error_type'], 'TimeoutError');
      expect(event.metadata.containsKey('status_code'), isFalse);
    });

    test('reports UnexpectedError without status_code', () async {
      final observability = FakeObservability();
      final container = _containerWith(
        _FakeExperienceRepository(result: _invalidConfiguration),
        observability: observability,
      );
      addTearDown(container.dispose);

      await container.read(experienceProvider.notifier).load();

      final event = observability.events.single;
      expect(event.name, 'experience_degraded');
      expect(event.metadata['error_type'], 'UnexpectedError');
      expect(event.metadata.containsKey('status_code'), isFalse);
    });

    test('does not report on success', () async {
      final observability = FakeObservability();
      final container = _containerWith(
        _FakeExperienceRepository(result: _loaded),
        observability: observability,
      );
      addTearDown(container.dispose);

      await container.read(experienceProvider.notifier).load();

      expect(observability.events, isEmpty);
    });
  });
}
