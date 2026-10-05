import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:digital_bank/core/network/auth_interceptor.dart';
import 'package:digital_bank/core/session/session_manager.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter({this.statusCode = 200, this.body = '{}'});

  final int statusCode;
  final String body;

  RequestOptions? lastRequestOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequestOptions = options;
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dioWith(_RecordingAdapter adapter) =>
    Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;

void main() {
  group('AuthInterceptor onRequest', () {
    test('API-001 attaches Authorization when a session exists', () async {
      final session = SessionManager()..setToken('token-a');
      final adapter = _RecordingAdapter();
      final dio = _dioWith(adapter)..interceptors.add(AuthInterceptor(session));

      await dio.get<dynamic>('/accounts');

      expect(
        adapter.lastRequestOptions?.headers['Authorization'],
        'Bearer token-a',
      );
    });

    test('API-002 does not attach Authorization without a session', () async {
      final session = SessionManager();
      final adapter = _RecordingAdapter();
      final dio = _dioWith(adapter)..interceptors.add(AuthInterceptor(session));

      await dio.get<dynamic>('/accounts');

      expect(
        adapter.lastRequestOptions?.headers.containsKey('Authorization'),
        isFalse,
      );
    });

    test('API-003 attaches the current token after it changes', () async {
      final session = SessionManager()..setToken('token-a');
      final adapter = _RecordingAdapter();
      final dio = _dioWith(adapter)..interceptors.add(AuthInterceptor(session));

      session.setToken('token-b');
      await dio.get<dynamic>('/accounts');

      expect(
        adapter.lastRequestOptions?.headers['Authorization'],
        'Bearer token-b',
      );
    });
  });

  group('AuthInterceptor onError', () {
    test('API-004 a 401 clears the session', () async {
      final session = SessionManager()..setToken('token-a');
      final adapter = _RecordingAdapter(statusCode: 401, body: '{}');
      final dio = _dioWith(adapter)..interceptors.add(AuthInterceptor(session));

      await expectLater(
        dio.get<dynamic>('/accounts'),
        throwsA(isA<DioException>()),
      );

      expect(session.hasSession, isFalse);
    });

    test('API-005 a non-401 error keeps the session', () async {
      final session = SessionManager()..setToken('token-a');
      final adapter = _RecordingAdapter(statusCode: 500, body: '{}');
      final dio = _dioWith(adapter)..interceptors.add(AuthInterceptor(session));

      await expectLater(
        dio.get<dynamic>('/accounts'),
        throwsA(isA<DioException>()),
      );

      expect(session.hasSession, isTrue);
    });

    test('API-006 a transport error keeps the session', () async {
      final session = SessionManager()..setToken('token-a');
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = _ThrowingAdapter()
        ..interceptors.add(AuthInterceptor(session));

      await expectLater(
        dio.get<dynamic>('/accounts'),
        throwsA(isA<DioException>()),
      );

      expect(session.hasSession, isTrue);
    });
  });
}

class _ThrowingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
      message: 'connection failed',
    );
  }

  @override
  void close({bool force = false}) {}
}
