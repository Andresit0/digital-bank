import 'package:dio/dio.dart';

class RetryPolicy {
  const RetryPolicy({
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 300),
    this.retryableStatusCodes = const {502, 503, 504},
  });

  final int maxRetries;
  final Duration baseDelay;
  final Set<int> retryableStatusCodes;

  int get maxAttempts => maxRetries + 1;

  bool canRetry(DioException error, {required int attempt}) {
    if (attempt > maxRetries) {
      return false;
    }
    if (!_isRetryableMethod(error.requestOptions.method)) {
      return false;
    }
    return _isRetryableError(error);
  }

  Duration delayBeforeRetry(int retryNumber) {
    final multiplier = 1 << (retryNumber - 1);
    return baseDelay * multiplier;
  }

  bool _isRetryableMethod(String method) => method.toUpperCase() == 'GET';

  bool _isRetryableError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return statusCode != null &&
            retryableStatusCodes.contains(statusCode);
      default:
        return false;
    }
  }
}
