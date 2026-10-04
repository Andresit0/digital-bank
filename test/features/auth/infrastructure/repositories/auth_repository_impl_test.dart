import 'package:digital_bank/features/auth/domain/entities/auth_session.dart';
import 'package:digital_bank/features/auth/infrastructure/datasources/auth_remote_data_source.dart';
import 'package:digital_bank/features/auth/infrastructure/models/auth_response_model.dart';
import 'package:digital_bank/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/exceptions/network_exception.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDataSource implements AuthRemoteDataSource {
  _FakeDataSource({this.model, this.error});

  final AuthResponseModel? model;
  final Object? error;

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    if (error != null) {
      throw error!;
    }
    return model!;
  }
}

void main() {
  group('AuthRepositoryImpl', () {
    test('AUTH-REPO-001 success returns Success(AuthSession)', () async {
      final repository = AuthRepositoryImpl(
        _FakeDataSource(
          model: const AuthResponseModel(accessToken: 'token-123'),
        ),
      );

      final result = await repository.login(
        email: 'customer@example.com',
        password: 'secret',
      );

      expect(result, isA<Success<AuthSession>>());
      expect((result as Success<AuthSession>).data.accessToken, 'token-123');
    });

    test('AUTH-REPO-002 401 returns Failure(ApiError 401)', () async {
      final repository = AuthRepositoryImpl(
        _FakeDataSource(
          error: const NetworkException(
            message: 'unauthorized',
            statusCode: 401,
          ),
        ),
      );

      final result = await repository.login(email: 'a@b.com', password: 'x');

      expect(result, isA<Failure<AuthSession>>());
      final error = (result as Failure<AuthSession>).error;
      expect(error, isA<ApiError>());
      expect((error as ApiError).statusCode, 401);
    });

    test('AUTH-REPO-003 5xx returns Failure(ApiError 500)', () async {
      final repository = AuthRepositoryImpl(
        _FakeDataSource(
          error: const NetworkException(
            message: 'server error',
            statusCode: 500,
          ),
        ),
      );

      final result = await repository.login(email: 'a@b.com', password: 'x');

      expect(result, isA<Failure<AuthSession>>());
      final error = (result as Failure<AuthSession>).error;
      expect(error, isA<ApiError>());
      expect((error as ApiError).statusCode, 500);
    });

    test(
      'AUTH-REPO-004 transport failure returns Failure(NetworkError)',
      () async {
        final repository = AuthRepositoryImpl(
          _FakeDataSource(error: const NetworkException(message: 'timeout')),
        );

        final result = await repository.login(email: 'a@b.com', password: 'x');

        expect(result, isA<Failure<AuthSession>>());
        expect((result as Failure<AuthSession>).error, isA<NetworkError>());
      },
    );
  });
}
