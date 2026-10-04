import 'package:digital_bank/core/network/network_exception.dart';
import 'package:digital_bank/features/auth/domain/entities/auth_session.dart';
import 'package:digital_bank/features/auth/domain/errors/auth_error.dart';
import 'package:digital_bank/features/auth/infrastructure/datasources/auth_remote_data_source.dart';
import 'package:digital_bank/features/auth/infrastructure/models/auth_response_model.dart';
import 'package:digital_bank/features/auth/infrastructure/repositories/auth_repository_impl.dart';
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
    test('maps a successful response to an AuthSession', () async {
      final repository = AuthRepositoryImpl(
        _FakeDataSource(
          model: const AuthResponseModel(accessToken: 'token-123'),
        ),
      );

      final session = await repository.login(
        email: 'customer@example.com',
        password: 'secret',
      );

      expect(session, isA<AuthSession>());
      expect(session.accessToken, 'token-123');
    });

    test('maps 401 to AuthError.InvalidCredentials', () async {
      final repository = AuthRepositoryImpl(
        _FakeDataSource(
          error: const NetworkException(
            message: 'unauthorized',
            statusCode: 401,
          ),
        ),
      );

      expect(
        () => repository.login(email: 'a@b.com', password: 'x'),
        throwsA(
          isA<AuthError>().having(
            (e) => e,
            'error',
            AuthError.invalidCredentials,
          ),
        ),
      );
    });

    test('maps 5xx to AuthError.Network', () async {
      final repository = AuthRepositoryImpl(
        _FakeDataSource(
          error: const NetworkException(
            message: 'server error',
            statusCode: 500,
          ),
        ),
      );

      expect(
        () => repository.login(email: 'a@b.com', password: 'x'),
        throwsA(isA<AuthError>().having((e) => e, 'error', AuthError.network)),
      );
    });

    test(
      'maps a transport failure without status to AuthError.Network',
      () async {
        final repository = AuthRepositoryImpl(
          _FakeDataSource(error: const NetworkException(message: 'timeout')),
        );

        expect(
          () => repository.login(email: 'a@b.com', password: 'x'),
          throwsA(
            isA<AuthError>().having((e) => e, 'error', AuthError.network),
          ),
        );
      },
    );
  });
}
