import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/error/result_guard.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) => guard(() async {
    final model = await _remoteDataSource.login(
      email: email,
      password: password,
    );
    return AuthSession(accessToken: model.accessToken);
  });
}
