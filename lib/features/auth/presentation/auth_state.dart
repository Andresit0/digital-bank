import 'package:digital_bank/shared/error/app_error.dart';

import '../domain/entities/auth_session.dart';

sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.session);

  final AuthSession session;
}

final class AuthFailure extends AuthState {
  const AuthFailure(this.error);

  final AppError error;
}
