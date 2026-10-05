import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:digital_bank/core/network/retry_policy.dart';

DioException _error({
  required DioExceptionType type,
  String method = 'GET',
  int? statusCode,
}) {
  final options = RequestOptions(path: '/accounts', method: method);
  return DioException(
    requestOptions: options,
    type: type,
    response: statusCode == null
        ? null
        : Response(requestOptions: options, statusCode: statusCode),
  );
}

void main() {
  const policy = RetryPolicy();

  group('RetryPolicy bounds', () {
    test('RES-001 maximum retries is 2', () {
      expect(policy.maxRetries, 2);
    });

    test('RES-001 maximum attempts is 3', () {
      expect(policy.maxAttempts, 3);
    });

    test('RES-002 retry #1 delay is 300ms', () {
      expect(policy.delayBeforeRetry(1), const Duration(milliseconds: 300));
    });

    test('RES-002 retry #2 delay is 600ms', () {
      expect(policy.delayBeforeRetry(2), const Duration(milliseconds: 600));
    });

    test('RES-002 delays are deterministic (no jitter)', () {
      expect(policy.delayBeforeRetry(1), policy.delayBeforeRetry(1));
      expect(policy.delayBeforeRetry(2), policy.delayBeforeRetry(2));
    });
  });

  group('RetryPolicy retryable errors', () {
    test('RES-001 connection error is retryable', () {
      expect(
        policy.canRetry(
          _error(type: DioExceptionType.connectionError),
          attempt: 1,
        ),
        isTrue,
      );
    });

    test('RES-001 connection timeout is retryable', () {
      expect(
        policy.canRetry(
          _error(type: DioExceptionType.connectionTimeout),
          attempt: 1,
        ),
        isTrue,
      );
    });

    test('RES-001 send timeout is retryable', () {
      expect(
        policy.canRetry(
          _error(type: DioExceptionType.sendTimeout),
          attempt: 1,
        ),
        isTrue,
      );
    });

    test('RES-001 receive timeout is retryable', () {
      expect(
        policy.canRetry(
          _error(type: DioExceptionType.receiveTimeout),
          attempt: 1,
        ),
        isTrue,
      );
    });

    test('RES-007 HTTP 502 is retryable', () {
      expect(
        policy.canRetry(
          _error(type: DioExceptionType.badResponse, statusCode: 502),
          attempt: 1,
        ),
        isTrue,
      );
    });

    test('RES-007 HTTP 503 is retryable', () {
      expect(
        policy.canRetry(
          _error(type: DioExceptionType.badResponse, statusCode: 503),
          attempt: 1,
        ),
        isTrue,
      );
    });

    test('RES-007 HTTP 504 is retryable', () {
      expect(
        policy.canRetry(
          _error(type: DioExceptionType.badResponse, statusCode: 504),
          attempt: 1,
        ),
        isTrue,
      );
    });
  });

  group('RetryPolicy non-retryable errors', () {
    test('RES-003 HTTP 400 is not retryable', () {
      expect(
        policy.canRetry(
          _error(type: DioExceptionType.badResponse, statusCode: 400),
          attempt: 1,
        ),
        isFalse,
      );
    });

    test('RES-004 HTTP 401 is not retryable', () {
      expect(
        policy.canRetry(
          _error(type: DioExceptionType.badResponse, statusCode: 401),
          attempt: 1,
        ),
        isFalse,
      );
    });

    test('RES-004 HTTP 403 is not retryable', () {
      expect(
        policy.canRetry(
          _error(type: DioExceptionType.badResponse, statusCode: 403),
          attempt: 1,
        ),
        isFalse,
      );
    });

    test('RES-003 HTTP 404 is not retryable', () {
      expect(
        policy.canRetry(
          _error(type: DioExceptionType.badResponse, statusCode: 404),
          attempt: 1,
        ),
        isFalse,
      );
    });

    test('RES-005 cancellation is not retryable', () {
      expect(
        policy.canRetry(_error(type: DioExceptionType.cancel), attempt: 1),
        isFalse,
      );
    });

    test('RES-006 POST is not retryable', () {
      expect(
        policy.canRetry(
          _error(type: DioExceptionType.connectionError, method: 'POST'),
          attempt: 1,
        ),
        isFalse,
      );
    });

    test('RES-001 retry is bounded at two retries', () {
      expect(
        policy.canRetry(
          _error(type: DioExceptionType.connectionError),
          attempt: 3,
        ),
        isFalse,
      );
    });
  });
}
