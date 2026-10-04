import 'package:digital_bank/core/network/http_client.dart';
import 'package:digital_bank/shared/exceptions/network_exception.dart';

import '../models/movement_model.dart';

abstract interface class MovementsRemoteDataSource {
  Future<List<MovementModel>> fetchMovements({required String accountId});
}

class MovementsRemoteDataSourceImpl implements MovementsRemoteDataSource {
  MovementsRemoteDataSourceImpl(this._httpClient);

  static const String _accountsPath = '/accounts';

  final HttpClient _httpClient;

  @override
  Future<List<MovementModel>> fetchMovements({
    required String accountId,
  }) async {
    final response = await _httpClient.get<List<dynamic>>(
      '$_accountsPath/$accountId/movements',
    );

    final data = response.data;
    if (data == null) {
      throw NetworkException(
        message: 'empty response body',
        statusCode: response.statusCode,
      );
    }

    try {
      return data
          .map((item) => MovementModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on NetworkException {
      rethrow;
    } catch (error) {
      throw NetworkException(
        message: 'invalid movements payload',
        statusCode: response.statusCode,
      );
    }
  }
}
