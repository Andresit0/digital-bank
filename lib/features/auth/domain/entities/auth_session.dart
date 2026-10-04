class AuthSession {
  const AuthSession({required this.accessToken});

  final String accessToken;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSession &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken;

  @override
  int get hashCode => accessToken.hashCode;
}
