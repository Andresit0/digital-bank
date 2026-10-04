import 'package:digital_bank/features/auth/domain/entities/auth_session.dart';
import 'package:digital_bank/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return const AuthSession(accessToken: 'token-123');
  }
}

void main() {
  group('AuthRepository contract', () {
    test('login returns an AuthSession for valid credentials', () async {
      final repository = _FakeAuthRepository();

      final session = await repository.login(
        email: 'customer@example.com',
        password: 'secret',
      );

      expect(session, isA<AuthSession>());
      expect(session.accessToken, isNotEmpty);
    });
  });
}
