import 'package:digital_bank/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthSession', () {
    test('exposes the access token', () {
      const session = AuthSession(accessToken: 'token-123');

      expect(session.accessToken, 'token-123');
    });

    test('supports value equality', () {
      const a = AuthSession(accessToken: 'token-123');
      const b = AuthSession(accessToken: 'token-123');

      expect(a, equals(b));
    });
  });
}
