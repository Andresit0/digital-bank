import 'package:digital_bank/features/auth/domain/entities/auth_session.dart';
import 'package:digital_bank/features/auth/domain/repositories/auth_repository.dart';
import 'package:digital_bank/features/auth/di/auth_providers.dart';
import 'package:digital_bank/features/auth/presentation/screens/login_screen.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.result});

  final Result<AuthSession>? result;

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    return result ?? const Success(AuthSession(accessToken: 'token-123'));
  }
}

Widget _wrap(AuthRepository repository) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: LoginScreen()),
  );
}

void main() {
  group('LoginScreen', () {
    testWidgets('renders email, password, and login button', (tester) async {
      await tester.pumpWidget(_wrap(_FakeAuthRepository()));

      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
    });

    testWidgets('shows a validation error for an empty email', (tester) async {
      await tester.pumpWidget(_wrap(_FakeAuthRepository()));

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows a validation error for an invalid email', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_FakeAuthRepository()));

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'not-an-email',
      );
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('shows an authentication error on invalid credentials', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          _FakeAuthRepository(
            result: const Failure<AuthSession>(ApiError(statusCode: 401)),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'customer@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'wrong',
      );
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('shows a recoverable error on network failure', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _FakeAuthRepository(
            result: const Failure<AuthSession>(NetworkError()),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'customer@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'secret',
      );
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
    });
  });
}
