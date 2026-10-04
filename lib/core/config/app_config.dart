class AppConfig {
  const AppConfig({required this.apiBaseUrl});

  final String apiBaseUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppConfig &&
          runtimeType == other.runtimeType &&
          apiBaseUrl == other.apiBaseUrl;

  @override
  int get hashCode => apiBaseUrl.hashCode;
}
