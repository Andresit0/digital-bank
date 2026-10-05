import 'package:dio/dio.dart';
import 'package:digital_bank/core/network/dio_http_client.dart';
import 'package:digital_bank/core/network/network_providers.dart';
import 'package:digital_bank/core/network/read_cache.dart';
import 'package:digital_bank/core/services/observability/observability_provider.dart';
import 'package:digital_bank/features/accounts/domain/entities/account.dart';
import 'package:digital_bank/features/accounts/infrastructure/datasources/accounts_remote_data_source.dart';
import 'package:digital_bank/features/accounts/infrastructure/repositories/accounts_repository_impl.dart';
import 'package:digital_bank/features/accounts/presentation/accounts_state.dart';
import 'package:digital_bank/features/accounts/presentation/notifiers/accounts_notifier.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/read.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/api_test_server.dart';
import '../../../support/fake_observability.dart';

AccountsRepositoryImpl _repositoryFor(ApiTestServer server) {
  final dio = Dio(BaseOptions(baseUrl: 'http://api.test'))
    ..httpClientAdapter = server;
  final httpClient = DioHttpClient(dio);
  final dataSource = AccountsRemoteDataSourceImpl(httpClient);
  return AccountsRepositoryImpl(dataSource, ReadCache());
}

void main() {
  group('Accounts integration flow', () {
    test('INT-ACC-001 loads accounts successfully', () async {
      final server = ApiTestServer.success([
        {
          'id': 'acc-1',
          'type': 'savings',
          'displayName': 'Savings Account',
          'maskedNumber': '****1234',
          'availableBalance': 1500.5,
        },
        {
          'id': 'acc-2',
          'type': 'checking',
          'displayName': 'Checking Account',
          'maskedNumber': '****5678',
          'availableBalance': 20.0,
        },
      ]);

      final result = await _repositoryFor(server).fetchAccounts();

      expect(server.lastRequest?.method, 'GET');
      expect(server.lastRequest?.path, '/accounts');
      expect(result, isA<Success<Read<List<Account>>>>());
      final read = (result as Success<Read<List<Account>>>).data;
      expect(read.source, ReadSource.remote);
      expect(read.data, hasLength(2));
      expect(read.data.first, isA<Account>());
      expect(read.data.first.type, AccountType.savings);
      expect(read.data.last.type, AccountType.checking);
    });

    test('INT-ACC-002 maps a server error to ApiError(500)', () async {
      final server = ApiTestServer.serverError();

      final result = await _repositoryFor(server).fetchAccounts();

      expect(result, isA<Failure<Read<List<Account>>>>());
      final error = (result as Failure<Read<List<Account>>>).error;
      expect(error, isA<ApiError>());
      expect((error as ApiError).statusCode, 500);
    });

    test('INT-ACC-003 maps a transport failure to NetworkError', () async {
      final server = ApiTestServer.closeConnection();

      final result = await _repositoryFor(server).fetchAccounts();

      expect(result, isA<Failure<Read<List<Account>>>>());
      expect(
        (result as Failure<Read<List<Account>>>).error,
        isA<NetworkError>(),
      );
    });

    test('INT-ACC-004 returns an empty list for an empty response', () async {
      final server = ApiTestServer.success(<dynamic>[]);

      final result = await _repositoryFor(server).fetchAccounts();

      expect(result, isA<Success<Read<List<Account>>>>());
      expect((result as Success<Read<List<Account>>>).data.data, isEmpty);
    });

    test(
      'OBS-INT-ACC-WIRING-001 load failure reports accounts_load_failed',
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

        await container.read(accountsProvider.notifier).load();

        expect(container.read(accountsProvider), isA<AccountsFailure>());
        expect(observability.events, hasLength(1));
        expect(observability.events.single.name, 'accounts_load_failed');
      },
    );
  });
}
