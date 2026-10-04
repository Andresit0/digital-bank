import 'package:digital_bank/core/session/session_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionManager', () {
    test('SES-001 has no session initially', () {
      final session = SessionManager();

      expect(session.hasSession, isFalse);
      expect(session.accessToken, isNull);
    });

    test('SES-002 setToken stores the token and starts a session', () {
      final session = SessionManager();

      session.setToken('token-a');

      expect(session.hasSession, isTrue);
      expect(session.accessToken, 'token-a');
    });

    test('SES-003 clear removes the token and the session', () {
      final session = SessionManager()..setToken('token-a');

      session.clear();

      expect(session.hasSession, isFalse);
      expect(session.accessToken, isNull);
    });

    test('SES-004 setToken replaces a previous token', () {
      final session = SessionManager()..setToken('token-a');

      session.setToken('token-b');

      expect(session.accessToken, 'token-b');
    });

    test('SES-005 an empty token does not start a session', () {
      final session = SessionManager();

      session.setToken('');

      expect(session.hasSession, isFalse);
      expect(session.accessToken, isNull);
    });
  });
}
