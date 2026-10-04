sealed class AuthError implements Exception {
  const AuthError();

  static const AuthError invalidCredentials = InvalidCredentialsError();
  static const AuthError network = NetworkAuthError();
}

final class InvalidCredentialsError extends AuthError {
  const InvalidCredentialsError();
}

final class NetworkAuthError extends AuthError {
  const NetworkAuthError();
}
