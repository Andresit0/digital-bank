import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/error/result_guard.dart';

import '../../domain/entities/account.dart';
import '../../domain/repositories/accounts_repository.dart';
import '../datasources/accounts_remote_data_source.dart';
import '../models/account_model.dart';

class AccountsRepositoryImpl implements AccountsRepository {
  AccountsRepositoryImpl(this._remoteDataSource);

  final AccountsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Account>>> fetchAccounts() => guard(() async {
    final models = await _remoteDataSource.fetchAccounts();
    return models.map(_toEntity).toList();
  });

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
}
