import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:digital_bank/core/network/retry_interceptor.dart';
import 'package:digital_bank/core/network/retry_policy.dart';

class RecordingSleeper {
  final List<Duration> recorded = [];

  Future<void> call(Duration duration) async {
    recorded.add(duration);
  }
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._respond);

  final Future<ResponseBody> Function(RequestOptions options, int call)
  _respond;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    return _respond(options, calls);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(String body, int statusCode) {
  return ResponseBody.fromString(
    body,
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

DioException _connectionError(RequestOptions options) {
  return DioException(
    requestOptions: options,
    type: DioExceptionType.connectionError,
  );
}

class _Harness {
  _Harness(this.adapter, {RetryPolicy policy = const RetryPolicy()}) {
    dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(
      RetryInterceptor(dio: dio, policy: policy, sleeper: sleeper.call),
    );
  }

  final _FakeAdapter adapter;
  final RecordingSleeper sleeper = RecordingSleeper();
  late final Dio dio;
}

void main() {
  group('RetryInterceptor', () {
    test('RES-001 GET transient failure is retried and succeeds', () async {
      final harness = _Harness(
        _FakeAdapter((options, call) async {
          if (call == 1) throw _connectionError(options);
          return _json('{"ok":true}', 200);
        }),
      );

      final response = await harness.dio.get<Map<String, dynamic>>(
        '/accounts',
      );

      expect(response.statusCode, 200);
      expect(harness.adapter.calls, 2);
      expect(harness.sleeper.recorded, const [Duration(milliseconds: 300)]);
    });

    test('RES-007 GET 502 is retried', () async {
      final harness = _Harness(
        _FakeAdapter((options, call) async {
          if (call == 1) return _json('{}', 502);
          return _json('{"ok":true}', 200);
        }),
      );

      final response = await harness.dio.get<Map<String, dynamic>>(
        '/accounts',
      );

      expect(response.statusCode, 200);
      expect(harness.adapter.calls, 2);
    });

    test('RES-007 GET 503 is retried', () async {
      final harness = _Harness(
        _FakeAdapter((options, call) async {
          if (call == 1) return _json('{}', 503);
          return _json('{"ok":true}', 200);
        }),
      );

      final response = await harness.dio.get<Map<String, dynamic>>(
        '/accounts',
      );

      expect(response.statusCode, 200);
      expect(harness.adapter.calls, 2);
    });

    test('RES-007 GET 504 is retried', () async {
      final harness = _Harness(
        _FakeAdapter((options, call) async {
          if (call == 1) return _json('{}', 504);
          return _json('{"ok":true}', 200);
        }),
      );

      final response = await harness.dio.get<Map<String, dynamic>>(
        '/accounts',
      );

      expect(response.statusCode, 200);
      expect(harness.adapter.calls, 2);
    });

    test('RES-002 the first retry waits 300ms', () async {
      final harness = _Harness(
        _FakeAdapter((options, call) async {
          if (call == 1) throw _connectionError(options);
          return _json('{"ok":true}', 200);
        }),
      );

      await harness.dio.get('/accounts');

      expect(harness.sleeper.recorded, const [Duration(milliseconds: 300)]);
    });

    test('RES-002 the second retry waits 600ms', () async {
      final harness = _Harness(
        _FakeAdapter((options, call) async {
          if (call <= 2) throw _connectionError(options);
          return _json('{"ok":true}', 200);
        }),
      );

      await harness.dio.get('/accounts');

      expect(harness.sleeper.recorded, const [
        Duration(milliseconds: 300),
        Duration(milliseconds: 600),
      ]);
      expect(harness.adapter.calls, 3);
    });

    test('RES-008 exhaustion propagates the failure after 3 attempts', () async {
      final harness = _Harness(
        _FakeAdapter((options, call) async => throw _connectionError(options)),
      );

      await expectLater(
        harness.dio.get('/accounts'),
        throwsA(isA<DioException>()),
      );

      expect(harness.adapter.calls, 3);
      expect(harness.sleeper.recorded, const [
        Duration(milliseconds: 300),
        Duration(milliseconds: 600),
      ]);
    });

    test('RES-006 POST is never retried', () async {
      final harness = _Harness(
        _FakeAdapter((options, call) async => throw _connectionError(options)),
      );

      await expectLater(
        harness.dio.post('/auth/login'),
        throwsA(isA<DioException>()),
      );

      expect(harness.adapter.calls, 1);
      expect(harness.sleeper.recorded, isEmpty);
    });

    test('RES-004 401 is never retried', () async {
      final harness = _Harness(
        _FakeAdapter((options, call) async => _json('{}', 401)),
      );

      await expectLater(
        harness.dio.get('/accounts'),
        throwsA(isA<DioException>()),
      );

      expect(harness.adapter.calls, 1);
      expect(harness.sleeper.recorded, isEmpty);
    });

    test('RES-004 403 is never retried', () async {
      final harness = _Harness(
        _FakeAdapter((options, call) async => _json('{}', 403)),
      );

      await expectLater(
        harness.dio.get('/accounts'),
        throwsA(isA<DioException>()),
      );

      expect(harness.adapter.calls, 1);
    });

    test('RES-003 4xx (404) is never retried', () async {
      final harness = _Harness(
        _FakeAdapter((options, call) async => _json('{}', 404)),
      );

      await expectLater(
        harness.dio.get('/accounts'),
        throwsA(isA<DioException>()),
      );

      expect(harness.adapter.calls, 1);
    });

    test('RES-005 cancellation is never retried', () async {
      final harness = _Harness(
        _FakeAdapter(
          (options, call) async => throw DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
          ),
        ),
      );

      await expectLater(
        harness.dio.get('/accounts'),
        throwsA(isA<DioException>()),
      );

      expect(harness.adapter.calls, 1);
      expect(harness.sleeper.recorded, isEmpty);
    });
  });
}
