import 'package:dio/dio.dart';
import 'package:digital_bank/core/network/dio_http_client.dart';
import 'package:digital_bank/core/network/network_providers.dart';
import 'package:digital_bank/core/services/observability/observability_provider.dart';
import 'package:digital_bank/features/movements/domain/entities/movement.dart';
import 'package:digital_bank/features/movements/infrastructure/datasources/movements_remote_data_source.dart';
import 'package:digital_bank/features/movements/infrastructure/repositories/movements_repository_impl.dart';
import 'package:digital_bank/features/movements/presentation/movements_state.dart';
import 'package:digital_bank/features/movements/presentation/notifiers/movements_notifier.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/api_test_server.dart';
import '../../../support/fake_observability.dart';

MovementsRepositoryImpl _repositoryFor(ApiTestServer server) {
  final dio = Dio(BaseOptions(baseUrl: 'http://api.test'))
    ..httpClientAdapter = server;
  final httpClient = DioHttpClient(dio);
  final dataSource = MovementsRemoteDataSourceImpl(httpClient);
  return MovementsRepositoryImpl(dataSource);
}

void main() {
  group('Movements integration flow', () {
    test('INT-MOV-001 loads movements for the account', () async {
      final server = ApiTestServer.success([
        {
          'id': 'mov-1',
          'accountId': 'acc-1',
          'type': 'credit',
          'amount': 500.0,
          'currency': 'USD',
          'description': 'Salary',
          'occurredAt': '2026-10-01T09:30:00.000Z',
        },
        {
          'id': 'mov-2',
          'accountId': 'acc-1',
          'type': 'debit',
          'amount': 125.5,
          'currency': 'USD',
          'description': 'Card purchase',
          'occurredAt': '2026-10-02T12:00:00.000Z',
        },
      ]);

      final result = await _repositoryFor(server)
          .fetchMovements(accountId: 'acc-1');

      expect(server.lastRequest?.method, 'GET');
      expect(server.lastRequest?.path, '/accounts/acc-1/movements');
      expect(result, isA<Success<List<Movement>>>());
      final movements = (result as Success<List<Movement>>).data;
      expect(movements, hasLength(2));
      expect(movements.first.type, MovementType.credit);
      expect(movements.last.type, MovementType.debit);
    });

    test('INT-MOV-002 returns an empty list for an empty response', () async {
      final server = ApiTestServer.success(<dynamic>[]);

      final result = await _repositoryFor(server)
          .fetchMovements(accountId: 'acc-1');

      expect(result, isA<Success<List<Movement>>>());
      expect((result as Success<List<Movement>>).data, isEmpty);
    });

    test('INT-MOV-003 maps a server error to ApiError(500)', () async {
      final server = ApiTestServer.serverError();

      final result = await _repositoryFor(server)
          .fetchMovements(accountId: 'acc-1');

      expect(result, isA<Failure<List<Movement>>>());
      final error = (result as Failure<List<Movement>>).error;
      expect(error, isA<ApiError>());
      expect((error as ApiError).statusCode, 500);
    });

    test('INT-MOV-004 maps a transport failure to NetworkError', () async {
      final server = ApiTestServer.closeConnection();

      final result = await _repositoryFor(server)
          .fetchMovements(accountId: 'acc-1');

      expect(result, isA<Failure<List<Movement>>>());
      expect((result as Failure<List<Movement>>).error, isA<NetworkError>());
    });

    test(
      'OBS-INT-MOV-WIRING-001 load failure reports movements_load_failed',
      () async {
        final server = ApiTestServer.serverError();
        final observability = FakeObservability();
        final dio = Dio(BaseOptions(baseUrl: 'http://api.test'))
          ..httpClientAdapter = server;
        final container = ProviderContainer(
          overrides: [
            dioProvider.overrideWithValue(dio),
            observabilityProvider.overrideWithValue(observability),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(movementsProvider.notifier)
            .load(accountId: 'acc-1');

        expect(container.read(movementsProvider), isA<MovementsFailure>());
        expect(observability.events, hasLength(1));
        expect(observability.events.single.name, 'movements_load_failed');
      },
    );
  });
}
