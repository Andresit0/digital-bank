import 'package:digital_bank/core/network/http_client.dart';
import 'package:digital_bank/core/network/network_exception.dart';

import '../models/auth_response_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._httpClient);

  static const String _loginPath = '/auth/login';

  final HttpClient _httpClient;

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _httpClient.post(
      _loginPath,
      data: {'email': email, 'password': password},
    );

    final data = response.data;
    if (data == null) {
      throw NetworkException(
        message: 'empty response body',
        statusCode: response.statusCode,
      );
    }

    return AuthResponseModel.fromJson(data);
  }
}
