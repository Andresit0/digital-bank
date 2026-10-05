import 'package:digital_bank/core/services/logging/logging_providers.dart';
import 'package:digital_bank/core/services/observability/observability_provider.dart';
import 'package:digital_bank/features/movements/di/movements_providers.dart';
import 'package:digital_bank/features/movements/domain/entities/movement.dart';
import 'package:digital_bank/features/movements/domain/repositories/movements_repository.dart';
import 'package:digital_bank/features/movements/presentation/movements_state.dart';
import 'package:digital_bank/features/movements/presentation/notifiers/movements_notifier.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/interfaces/i_logger.dart';
import 'package:digital_bank/shared/interfaces/i_observability.dart';
import 'package:digital_bank/shared/observability/observability_severity.dart';
import 'package:digital_bank/shared/read.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fake_observability.dart';
import '../../../../support/observability_policy.dart';

class _FakeMovementsRepository implements MovementsRepository {
  _FakeMovementsRepository({this.result, this.sequence});

  final Result<Read<List<Movement>>>? result;
  final List<Result<Read<List<Movement>>>>? sequence;
  String? lastAccountId;
  int _calls = 0;

  @override
  Future<Result<Read<List<Movement>>>> fetchMovements({
    required String accountId,
  }) async {
    lastAccountId = accountId;
    final queued = sequence;
    if (queued != null && queued.isNotEmpty) {
      final index = _calls < queued.length ? _calls : queued.length - 1;
      _calls++;
      return queued[index];
    }
    return result!;
  }
}

class _ThrowingLogger implements ILogger {
  @override
  void info(String message, {String? technicalMessage}) {
    throw StateError(
      'ILogger.info must not be called for a reportable failure',
    );
  }

  @override
  void error(
    String message, {
    Object? technicalMessage,
    StackTrace? stackTrace,
  }) {
    throw StateError(
      'ILogger.error must not be called for a reportable failure',
    );
  }
}

Movement _movement({String type = 'credit', String accountId = 'acc-1'}) {
  return Movement(
    id: 'mov-1',
    accountId: accountId,
    type: type == 'credit' ? MovementType.credit : MovementType.debit,
    amount: 500.0,
    currency: 'USD',
    description: 'Salary',
    occurredAt: DateTime.utc(2026, 10, 1),
  );
}

Result<Read<List<Movement>>> _remote(List<Movement> movements) {
  return Success(
    Read<List<Movement>>(movements, source: ReadSource.remote),
  );
}

Result<Read<List<Movement>>> _cached(List<Movement> movements) {
  return Success(
    Read<List<Movement>>(movements, source: ReadSource.cache),
  );
}

ProviderContainer _containerWith(
  MovementsRepository repository, {
  IObservability? observability,
  ILogger? logger,
}) {
  return ProviderContainer(
    overrides: [
      movementsRepositoryProvider.overrideWithValue(repository),
      if (observability != null)
        observabilityProvider.overrideWithValue(observability),
      if (logger != null) loggerProvider.overrideWithValue(logger),
    ],
  );
}

void main() {
  group('MovementsNotifier', () {
    test('starts in the initial state', () {
      final container = _containerWith(
        _FakeMovementsRepository(result: _remote(const [])),
      );
      addTearDown(container.dispose);

      expect(container.read(movementsProvider), isA<MovementsInitial>());
    });

    test('load requires an accountId and emits loading then loaded', () async {
      final repository = _FakeMovementsRepository(
        result: _remote([_movement()]),
      );
      final container = _containerWith(repository);
      addTearDown(container.dispose);

      final future = container
          .read(movementsProvider.notifier)
          .load(accountId: 'acc-1');

      expect(container.read(movementsProvider), isA<MovementsLoading>());

      await future;

      expect(repository.lastAccountId, 'acc-1');
      final state = container.read(movementsProvider);
      expect(state, isA<MovementsLoaded>());
      expect((state as MovementsLoaded).movements, hasLength(1));
    });

    test('empty result emits empty', () async {
      final container = _containerWith(
        _FakeMovementsRepository(result: _remote(const [])),
      );
      addTearDown(container.dispose);

      await container.read(movementsProvider.notifier).load(accountId: 'acc-1');

      expect(container.read(movementsProvider), isA<MovementsEmpty>());
    });

    test('failure emits failure with the mapped AppError', () async {
      final container = _containerWith(
        _FakeMovementsRepository(
          result: const Failure<Read<List<Movement>>>(
            ApiError(statusCode: 500),
          ),
        ),
      );
      addTearDown(container.dispose);

      await container.read(movementsProvider.notifier).load(accountId: 'acc-1');

      final state = container.read(movementsProvider);
      expect(state, isA<MovementsFailure>());
      expect((state as MovementsFailure).error, isA<ApiError>());
    });

    test(
      'failure reports exactly one event and does not use ILogger',
      () async {
        final observability = FakeObservability();
        final container = _containerWith(
          _FakeMovementsRepository(
            result: const Failure<Read<List<Movement>>>(NetworkError()),
          ),
          observability: observability,
          logger: _ThrowingLogger(),
        );
        addTearDown(container.dispose);

        await container
            .read(movementsProvider.notifier)
            .load(accountId: 'acc-1');

        expect(observability.events, hasLength(1));
      },
    );

    test('captured events respect the sensitive-data policy', () async {
      final observability = FakeObservability();
      final container = _containerWith(
        _FakeMovementsRepository(
          result: const Failure<Read<List<Movement>>>(
            NetworkError(technicalMessage: 'connection refused'),
          ),
        ),
        observability: observability,
      );
      addTearDown(container.dispose);

      await container.read(movementsProvider.notifier).load(accountId: 'acc-1');

      expectEventsRespectSensitiveDataPolicy(observability.events);
    });

    test('server error reports movements_load_failed with metadata', () async {
      final observability = FakeObservability();
      final container = _containerWith(
        _FakeMovementsRepository(
          result: const Failure<Read<List<Movement>>>(
            ApiError(statusCode: 500),
          ),
        ),
        observability: observability,
      );
      addTearDown(container.dispose);

      await container.read(movementsProvider.notifier).load(accountId: 'acc-1');

      final event = observability.events.single;
      expect(event.name, 'movements_load_failed');
      expect(event.severity, ObservabilitySeverity.warning);
      expect(event.metadata['errorType'], 'ApiError');
      expect(event.metadata['statusCode'], 500);
    });

    test(
      'network failure reports movements_load_failed without statusCode',
      () async {
        final observability = FakeObservability();
        final container = _containerWith(
          _FakeMovementsRepository(
            result: const Failure<Read<List<Movement>>>(NetworkError()),
          ),
          observability: observability,
        );
        addTearDown(container.dispose);

        await container
            .read(movementsProvider.notifier)
            .load(accountId: 'acc-1');

        final event = observability.events.single;
        expect(event.name, 'movements_load_failed');
        expect(event.metadata['errorType'], 'NetworkError');
        expect(event.metadata.containsKey('statusCode'), isFalse);
      },
    );

    test('MOV-NOT-007 remote read emits MovementsLoaded', () async {
      final container = _containerWith(
        _FakeMovementsRepository(result: _remote([_movement()])),
      );
      addTearDown(container.dispose);

      await container.read(movementsProvider.notifier).load(accountId: 'acc-1');

      final state = container.read(movementsProvider);
      expect(state, isA<MovementsLoaded>());
      expect((state as MovementsLoaded).movements, hasLength(1));
    });

    test('MOV-NOT-008 cached read emits MovementsStale', () async {
      final container = _containerWith(
        _FakeMovementsRepository(result: _cached([_movement()])),
      );
      addTearDown(container.dispose);

      await container.read(movementsProvider.notifier).load(accountId: 'acc-1');

      final state = container.read(movementsProvider);
      expect(state, isA<MovementsStale>());
      final stale = state as MovementsStale;
      expect(stale.movements, hasLength(1));
      expect(stale.movements.first.accountId, 'acc-1');
    });

    test('MOV-NOT-009 stale -> retry -> loading -> remote recovery', () async {
      final repository = _FakeMovementsRepository(
        sequence: [
          _cached([_movement()]),
          _remote([_movement()]),
        ],
      );
      final container = _containerWith(repository);
      addTearDown(container.dispose);

      final notifier = container.read(movementsProvider.notifier);

      await notifier.load(accountId: 'acc-1');
      expect(container.read(movementsProvider), isA<MovementsStale>());

      final future = notifier.load(accountId: 'acc-1');
      expect(container.read(movementsProvider), isA<MovementsLoading>());

      await future;
      expect(container.read(movementsProvider), isA<MovementsLoaded>());
      expect(repository.lastAccountId, 'acc-1');
    });

    test('MOV-NOT-010 failure -> retry -> loading -> recovery', () async {
      final repository = _FakeMovementsRepository(
        sequence: [
          const Failure<Read<List<Movement>>>(NetworkError()),
          _remote([_movement()]),
        ],
      );
      final container = _containerWith(repository);
      addTearDown(container.dispose);

      final notifier = container.read(movementsProvider.notifier);

      await notifier.load(accountId: 'acc-1');
      expect(container.read(movementsProvider), isA<MovementsFailure>());

      final future = notifier.load(accountId: 'acc-1');
      expect(container.read(movementsProvider), isA<MovementsLoading>());

      await future;
      expect(container.read(movementsProvider), isA<MovementsLoaded>());
      expect(repository.lastAccountId, 'acc-1');
    });

    test('MOV-NOT-011 cached read reports movements_stale_served', () async {
      final observability = FakeObservability();
      final container = _containerWith(
        _FakeMovementsRepository(result: _cached([_movement()])),
        observability: observability,
      );
      addTearDown(container.dispose);

      await container.read(movementsProvider.notifier).load(accountId: 'acc-1');

      final event = observability.events.single;
      expect(event.name, 'movements_stale_served');
      expectEventsRespectSensitiveDataPolicy(observability.events);
    });
  });
}
