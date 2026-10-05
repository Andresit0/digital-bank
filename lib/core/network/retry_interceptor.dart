import 'package:dio/dio.dart';

import '../../shared/interfaces/i_observability.dart';
import '../../shared/observability/observability_event.dart';
import '../../shared/observability/observability_severity.dart';
import 'retry_policy.dart';

typedef RetrySleeper = Future<void> Function(Duration duration);

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this._dio,
    required this.observability,
    this.policy = const RetryPolicy(),
    RetrySleeper? sleeper,
  })  : _sleeper = sleeper ?? _defaultSleeper;

  static const String _attemptKey = 'retry_attempt';

  final Dio _dio;
  final IObservability observability;
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

    observability.report(_retriedEvent(options, nextAttempt));

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

  ObservabilityEvent _retriedEvent(RequestOptions options, int attempt) {
    return ObservabilityEvent(
      name: 'request_retried',
      severity: ObservabilitySeverity.info,
      metadata: <String, Object?>{
        'attempt': attempt,
        'endpoint': options.uri.path,
      },
    );
  }

  int _readAttempt(RequestOptions options) {
    final value = options.extra[_attemptKey];
    return value is int ? value : 0;
  }
}
