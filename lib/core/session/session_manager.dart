class SessionManager {
  String? _accessToken;

  String? get accessToken => _accessToken;

  bool get hasSession => _accessToken != null;

  void setToken(String token) {
    if (token.isEmpty) {
      return;
    }
    _accessToken = token;
  }

  void clear() {
    _accessToken = null;
  }
}
