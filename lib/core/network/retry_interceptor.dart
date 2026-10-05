import 'package:dio/dio.dart';

import 'retry_policy.dart';

typedef RetrySleeper = Future<void> Function(Duration duration);

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required Dio dio,
    this.policy = const RetryPolicy(),
    RetrySleeper? sleeper,
  })  : _dio = dio,
        _sleeper = sleeper ?? _defaultSleeper;

  static const String _attemptKey = 'retry_attempt';

  final Dio _dio;
  final RetryPolicy policy;
  final RetrySleeper _sleeper;

  static Future<void> _defaultSleeper(Duration duration) =>
      Future<void>.delayed(duration);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final nextAttempt = _readAttempt(options) + 1;

    if (!policy.canRetry(err, attempt: nextAttempt)) {
      handler.next(err);
      return;
    }

    options.extra[_attemptKey] = nextAttempt;

    await _sleeper(policy.delayBeforeRetry(nextAttempt));

    try {
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (_) {
      handler.next(err);
    }
  }

  int _readAttempt(RequestOptions options) {
    final value = options.extra[_attemptKey];
    return value is int ? value : 0;
  }
}
