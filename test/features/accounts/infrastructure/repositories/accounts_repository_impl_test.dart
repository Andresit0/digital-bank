import 'package:digital_bank/shared/exceptions/network_exception.dart';
import 'package:digital_bank/features/accounts/domain/entities/account.dart';
import 'package:digital_bank/features/accounts/domain/errors/accounts_error.dart';
import 'package:digital_bank/features/accounts/infrastructure/datasources/accounts_remote_data_source.dart';
import 'package:digital_bank/features/accounts/infrastructure/models/account_model.dart';
import 'package:digital_bank/features/accounts/infrastructure/repositories/accounts_repository_impl.dart';
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
    test('maps models to domain accounts', () async {
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

      final accounts = await repository.fetchAccounts();

      expect(accounts, hasLength(1));
      expect(accounts.first, isA<Account>());
      expect(accounts.first.type, AccountType.savings);
    });

    test('returns an empty list for an empty response', () async {
      final repository = AccountsRepositoryImpl(
        _FakeDataSource(models: const []),
      );

      final accounts = await repository.fetchAccounts();

      expect(accounts, isEmpty);
    });

    test('maps 401 to AccountsError.invalidCredentials', () async {
      final repository = AccountsRepositoryImpl(
        _FakeDataSource(
          error: const NetworkException(
            message: 'unauthorized',
            statusCode: 401,
          ),
        ),
      );

      expect(
        () => repository.fetchAccounts(),
        throwsA(
          isA<AccountsError>().having(
            (error) => error,
            'error',
            AccountsError.invalidCredentials,
          ),
        ),
      );
    });

    test('maps 5xx to AccountsError.network', () async {
      final repository = AccountsRepositoryImpl(
        _FakeDataSource(
          error: const NetworkException(
            message: 'server error',
            statusCode: 500,
          ),
        ),
      );

      expect(
        () => repository.fetchAccounts(),
        throwsA(
          isA<AccountsError>().having(
            (error) => error,
            'error',
            AccountsError.network,
          ),
        ),
      );
    });

    test(
      'maps a transport failure without status to AccountsError.network',
      () async {
        final repository = AccountsRepositoryImpl(
          _FakeDataSource(error: const NetworkException(message: 'timeout')),
        );

        expect(
          () => repository.fetchAccounts(),
          throwsA(
            isA<AccountsError>().having(
              (error) => error,
              'error',
              AccountsError.network,
            ),
          ),
        );
      },
    );

    test('maps an invalid payload to AccountsError.network', () async {
      final repository = AccountsRepositoryImpl(
        _FakeDataSource(
          error: const NetworkException(
            message: 'invalid accounts payload',
            statusCode: 200,
          ),
        ),
      );

      expect(
        () => repository.fetchAccounts(),
        throwsA(
          isA<AccountsError>().having(
            (error) => error,
            'error',
            AccountsError.network,
          ),
        ),
      );
    });
  });
}
