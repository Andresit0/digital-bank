import 'package:digital_bank/core/network/http_client.dart';
import 'package:digital_bank/core/network/network_exception.dart';

import '../models/account_model.dart';

abstract interface class AccountsRemoteDataSource {
  Future<List<AccountModel>> fetchAccounts();
}

class AccountsRemoteDataSourceImpl implements AccountsRemoteDataSource {
  AccountsRemoteDataSourceImpl(this._httpClient);

  static const String _accountsPath = '/accounts';

  final HttpClient _httpClient;

  @override
  Future<List<AccountModel>> fetchAccounts() async {
    final response = await _httpClient.get<List<dynamic>>(_accountsPath);

    final data = response.data;
    if (data == null) {
      throw NetworkException(
        message: 'empty response body',
        statusCode: response.statusCode,
      );
    }

    try {
      return data
          .map((item) => AccountModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on NetworkException {
      rethrow;
    } catch (error) {
      throw NetworkException(
        message: 'invalid accounts payload',
        statusCode: response.statusCode,
      );
    }
  }
}
