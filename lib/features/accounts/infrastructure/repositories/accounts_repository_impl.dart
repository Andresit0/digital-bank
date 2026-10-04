import 'package:digital_bank/shared/exceptions/network_exception.dart';

import '../../domain/entities/account.dart';
import '../../domain/errors/accounts_error.dart';
import '../../domain/repositories/accounts_repository.dart';
import '../datasources/accounts_remote_data_source.dart';
import '../models/account_model.dart';

class AccountsRepositoryImpl implements AccountsRepository {
  AccountsRepositoryImpl(this._remoteDataSource);

  final AccountsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Account>> fetchAccounts() async {
    try {
      final models = await _remoteDataSource.fetchAccounts();
      return models.map(_toEntity).toList();
    } on NetworkException catch (error) {
      throw _mapError(error);
    }
  }

  Account _toEntity(AccountModel model) {
    return Account(
      id: model.id,
      type: model.type == 'savings'
          ? AccountType.savings
          : AccountType.checking,
      displayName: model.displayName,
      maskedNumber: model.maskedNumber,
      availableBalance: model.availableBalance,
    );
  }

  AccountsError _mapError(NetworkException error) {
    if (error.statusCode == 401) {
      return AccountsError.invalidCredentials;
    }
    return AccountsError.network;
  }
}
