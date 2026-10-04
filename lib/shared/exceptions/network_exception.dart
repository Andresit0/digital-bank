class NetworkException implements Exception {
  const NetworkException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;
}
