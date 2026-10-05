import 'package:digital_bank/core/network/read_cache.dart';
import 'package:digital_bank/features/accounts/domain/entities/account.dart';
import 'package:digital_bank/features/accounts/infrastructure/datasources/accounts_remote_data_source.dart';
import 'package:digital_bank/features/accounts/infrastructure/models/account_model.dart';
import 'package:digital_bank/features/accounts/infrastructure/repositories/accounts_repository_impl.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/exceptions/network_exception.dart';
import 'package:digital_bank/shared/read.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDataSource implements AccountsRemoteDataSource {
  _FakeDataSource({this.models, this.error});

  final List<AccountModel>? models;
  final Object? error;

  @override
  Future<List<AccountModel>> fetchAccounts() async {
    if (error != null) {
      throw error!;
    }
    return models!;
  }
}

AccountModel _model({String id = 'acc-1'}) {
  return AccountModel(
    id: id,
    type: 'savings',
    displayName: 'Savings Account',
    maskedNumber: '****1234',
    availableBalance: 1500.5,
  );
}

const _cachedAccount = Account(
  id: 'acc-1',
  type: AccountType.savings,
  displayName: 'Savings Account',
  maskedNumber: '****1234',
  availableBalance: 1500.5,
);

void main() {
  group('AccountsRepositoryImpl', () {
    test('ACC-REPO-001 remote accounts are read as ReadSource.remote', () async {
      final repository = AccountsRepositoryImpl(
        _FakeDataSource(models: [_model()]),
        ReadCache(),
      );

      final result = await repository.fetchAccounts();

      expect(result, isA<Success<Read<List<Account>>>>());
      final read = (result as Success<Read<List<Account>>>).data;
      expect(read.source, ReadSource.remote);
      expect(read.data, hasLength(1));
      expect(read.data.first, isA<Account>());
      expect(read.data.first.type, AccountType.savings);
    });

    test('ACC-REPO-002 remote accounts are cached under accounts', () async {
      final readCache = ReadCache();
      final repository = AccountsRepositoryImpl(
        _FakeDataSource(models: [_model()]),
        readCache,
      );

      await repository.fetchAccounts();

      final cached = readCache.get('accounts');
      expect(cached, isA<List<Account>>());
      expect(cached as List<Account>, hasLength(1));
    });

    test(
      'ACC-REPO-003 remote failure with cache returns ReadSource.cache',
      () async {
        final readCache = ReadCache()..put('accounts', const [_cachedAccount]);
        final repository = AccountsRepositoryImpl(
          _FakeDataSource(error: const NetworkException(message: 'timeout')),
          readCache,
        );

        final result = await repository.fetchAccounts();

        expect(result, isA<Success<Read<List<Account>>>>());
        final read = (result as Success<Read<List<Account>>>).data;
        expect(read.source, ReadSource.cache);
        expect(read.data, const [_cachedAccount]);
      },
    );

    test('ACC-REPO-004 remote failure without cache returns Failure', () async {
      final repository = AccountsRepositoryImpl(
        _FakeDataSource(error: const NetworkException(message: 'timeout')),
        ReadCache(),
      );

      final result = await repository.fetchAccounts();

      expect(result, isA<Failure<Read<List<Account>>>>());
      expect(
        (result as Failure<Read<List<Account>>>).error,
        isA<NetworkError>(),
      );
    });

    test('ACC-REPO-005 cache is not written when the remote fails', () async {
      final readCache = ReadCache();
      final repository = AccountsRepositoryImpl(
        _FakeDataSource(error: const NetworkException(message: 'timeout')),
        readCache,
      );

      await repository.fetchAccounts();

      expect(readCache.get('accounts'), isNull);
    });

    test('ACC-REPO-006 401 returns Failure(ApiError 401)', () async {
      final repository = AccountsRepositoryImpl(
        _FakeDataSource(
          error: const NetworkException(
            message: 'unauthorized',
            statusCode: 401,
          ),
        ),
        ReadCache(),
      );

      final result = await repository.fetchAccounts();

      expect(result, isA<Failure<Read<List<Account>>>>());
      final error = (result as Failure<Read<List<Account>>>).error;
      expect(error, isA<ApiError>());
      expect((error as ApiError).statusCode, 401);
    });

    test('ACC-REPO-007 5xx returns Failure(ApiError 500)', () async {
      final repository = AccountsRepositoryImpl(
        _FakeDataSource(
          error: const NetworkException(
            message: 'server error',
            statusCode: 500,
          ),
        ),
        ReadCache(),
      );

      final result = await repository.fetchAccounts();

      expect(result, isA<Failure<Read<List<Account>>>>());
      final error = (result as Failure<Read<List<Account>>>).error;
      expect(error, isA<ApiError>());
      expect((error as ApiError).statusCode, 500);
    });

    test(
      'ACC-REPO-008 transport failure returns Failure(NetworkError)',
      () async {
        final repository = AccountsRepositoryImpl(
          _FakeDataSource(error: const NetworkException(message: 'timeout')),
          ReadCache(),
        );

        final result = await repository.fetchAccounts();

        expect(result, isA<Failure<Read<List<Account>>>>());
        expect(
          (result as Failure<Read<List<Account>>>).error,
          isA<NetworkError>(),
        );
      },
    );

    test(
      'ACC-REPO-009 invalid payload (200) returns Failure(ApiError 200)',
      () async {
        final repository = AccountsRepositoryImpl(
          _FakeDataSource(
            error: const NetworkException(
              message: 'invalid accounts payload',
              statusCode: 200,
            ),
          ),
          ReadCache(),
        );

        final result = await repository.fetchAccounts();

        expect(result, isA<Failure<Read<List<Account>>>>());
        final error = (result as Failure<Read<List<Account>>>).error;
        expect(error, isA<ApiError>());
        expect((error as ApiError).statusCode, 200);
      },
    );
  });
}
