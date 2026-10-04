import 'package:digital_bank/shared/exceptions/network_exception.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/errors/auth_error.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      return AuthSession(accessToken: model.accessToken);
    } on NetworkException catch (error) {
      throw _mapError(error);
    }
  }

  AuthError _mapError(NetworkException error) {
    if (error.statusCode == 401) {
      return AuthError.invalidCredentials;
    }
    return AuthError.network;
  }
}
