import 'package:digital_bank/features/auth/domain/entities/auth_session.dart';
import 'package:digital_bank/features/auth/domain/repositories/auth_repository.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    return const Success(AuthSession(accessToken: 'token-123'));
  }
}

void main() {
  group('AuthRepository contract', () {
    test(
      'login returns Success with an AuthSession for valid credentials',
      () async {
        final repository = _FakeAuthRepository();

        final result = await repository.login(
          email: 'customer@example.com',
          password: 'secret',
        );

        expect(result, isA<Success<AuthSession>>());
        expect((result as Success<AuthSession>).data.accessToken, isNotEmpty);
      },
    );
  });
}
