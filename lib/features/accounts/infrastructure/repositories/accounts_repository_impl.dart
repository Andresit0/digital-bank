import 'package:digital_bank/core/network/read_cache.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/error/result_guard.dart';
import 'package:digital_bank/shared/read.dart';

import '../../domain/entities/account.dart';
import '../../domain/repositories/accounts_repository.dart';
import '../datasources/accounts_remote_data_source.dart';
import '../models/account_model.dart';

class AccountsRepositoryImpl implements AccountsRepository {
  AccountsRepositoryImpl(this._remoteDataSource, this._readCache);

  static const String _cacheKey = 'accounts';

  final AccountsRemoteDataSource _remoteDataSource;
  final ReadCache _readCache;

  @override
  Future<Result<Read<List<Account>>>> fetchAccounts() async {
    final result = await guard(() async {
      final models = await _remoteDataSource.fetchAccounts();
      return models.map(_toEntity).toList();
    });

    return result.when(
      success: (accounts) {
        _readCache.put(_cacheKey, accounts);
        return Success<Read<List<Account>>>(
          Read<List<Account>>(accounts, source: ReadSource.remote),
        );
      },
      failure: (error) {
        final cached = _readCache.get(_cacheKey);
        if (cached is List<Account>) {
          return Success<Read<List<Account>>>(
            Read<List<Account>>(cached, source: ReadSource.cache),
          );
        }
        return Failure<Read<List<Account>>>(error);
      },
    );
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
}
