import 'package:digital_bank/features/accounts/domain/entities/account.dart';
import 'package:digital_bank/features/accounts/infrastructure/datasources/accounts_remote_data_source.dart';
import 'package:digital_bank/features/accounts/infrastructure/models/account_model.dart';
import 'package:digital_bank/features/accounts/infrastructure/repositories/accounts_repository_impl.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/exceptions/network_exception.dart';
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

void main() {
  group('AccountsRepositoryImpl', () {
    test('ACC-REPO-001 success returns Success(List<Account>)', () async {
      final repository = AccountsRepositoryImpl(
        _FakeDataSource(
          models: const [
            AccountModel(
              id: 'acc-1',
              type: 'savings',
              displayName: 'Savings Account',
              maskedNumber: '****1234',
              availableBalance: 1500.5,
            ),
          ],
        ),
      );

      final result = await repository.fetchAccounts();

      expect(result, isA<Success<List<Account>>>());
      final accounts = (result as Success<List<Account>>).data;
      expect(accounts, hasLength(1));
      expect(accounts.first, isA<Account>());
      expect(accounts.first.type, AccountType.savings);
    });

    test('ACC-REPO-002 401 returns Failure(ApiError 401)', () async {
      final repository = AccountsRepositoryImpl(
        _FakeDataSource(
          error: const NetworkException(
            message: 'unauthorized',
            statusCode: 401,
          ),
        ),
      );

      final result = await repository.fetchAccounts();

      expect(result, isA<Failure<List<Account>>>());
      final error = (result as Failure<List<Account>>).error;
      expect(error, isA<ApiError>());
      expect((error as ApiError).statusCode, 401);
    });

    test('ACC-REPO-003 5xx returns Failure(ApiError 500)', () async {
      final repository = AccountsRepositoryImpl(
        _FakeDataSource(
          error: const NetworkException(
            message: 'server error',
            statusCode: 500,
          ),
        ),
      );

      final result = await repository.fetchAccounts();

      expect(result, isA<Failure<List<Account>>>());
      final error = (result as Failure<List<Account>>).error;
      expect(error, isA<ApiError>());
      expect((error as ApiError).statusCode, 500);
    });

    test(
      'ACC-REPO-004 transport failure returns Failure(NetworkError)',
      () async {
        final repository = AccountsRepositoryImpl(
          _FakeDataSource(error: const NetworkException(message: 'timeout')),
        );

        final result = await repository.fetchAccounts();

        expect(result, isA<Failure<List<Account>>>());
        expect((result as Failure<List<Account>>).error, isA<NetworkError>());
      },
    );

    test(
      'ACC-REPO-005 invalid payload (200) returns Failure(ApiError 200)',
      () async {
        final repository = AccountsRepositoryImpl(
          _FakeDataSource(
            error: const NetworkException(
              message: 'invalid accounts payload',
              statusCode: 200,
            ),
          ),
        );

        final result = await repository.fetchAccounts();

        expect(result, isA<Failure<List<Account>>>());
        final error = (result as Failure<List<Account>>).error;
        expect(error, isA<ApiError>());
        expect((error as ApiError).statusCode, 200);
      },
    );
  });
}
