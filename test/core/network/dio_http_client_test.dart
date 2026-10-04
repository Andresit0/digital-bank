import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:digital_bank/core/network/dio_http_client.dart';
import 'package:digital_bank/shared/exceptions/network_exception.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestHttpClientAdapter implements HttpClientAdapter {
  _TestHttpClientAdapter({this.response, this.error});

  final Object? response;
  final DioException? error;

  RequestOptions? lastRequestOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequestOptions = options;
    if (error != null) {
      throw error!;
    }
    if (response != null) {
      return ResponseBody.fromString(
        jsonEncode(response),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
      message: 'connection failed',
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('DioHttpClient.get', () {
    test(
      'delegates the request through Dio and returns a Map response',
      () async {
        final adapter = _TestHttpClientAdapter(
          response: {'id': 1, 'name': 'Ada'},
        );
        final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
          ..httpClientAdapter = adapter;
        final client = DioHttpClient(dio);

        final response = await client.get<Map<String, dynamic>>('/users/1');

        expect(adapter.lastRequestOptions?.method, 'GET');
        expect(adapter.lastRequestOptions?.path, '/users/1');
        expect(response.statusCode, 200);
        expect(response.data, {'id': 1, 'name': 'Ada'});
      },
    );

    test(
      'delegates the request through Dio and returns a List response',
      () async {
        final adapter = _TestHttpClientAdapter(
          response: [
            {'id': 'acc-1', 'availableBalance': 1500.5},
            {'id': 'acc-2', 'availableBalance': 20.0},
          ],
        );
        final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
          ..httpClientAdapter = adapter;
        final client = DioHttpClient(dio);

        final response = await client.get<List<dynamic>>('/accounts');

        expect(adapter.lastRequestOptions?.method, 'GET');
        expect(adapter.lastRequestOptions?.path, '/accounts');
        expect(response.statusCode, 200);
        expect(response.data, isA<List<dynamic>>());
        expect(response.data, hasLength(2));
      },
    );
  });

  group('DioHttpClient.post', () {
    test('delegates the body through Dio and returns the response', () async {
      final adapter = _TestHttpClientAdapter(response: {'token': 'abc'});
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = adapter;
      final client = DioHttpClient(dio);

      final response = await client.post(
        '/login',
        data: {'email': 'a@b.com', 'password': 'secret'},
      );

      expect(adapter.lastRequestOptions?.method, 'POST');
      expect(adapter.lastRequestOptions?.data, {
        'email': 'a@b.com',
        'password': 'secret',
      });
      expect(response.statusCode, 200);
      expect(response.data, {'token': 'abc'});
    });
  });

  group('DioHttpClient error mapping', () {
    test('maps DioException to NetworkException', () async {
      final requestOptions = RequestOptions(
        path: '/users/1',
        baseUrl: 'https://example.test',
      );
      final dioException = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
          data: {'message': 'Unauthorized'},
        ),
        type: DioExceptionType.badResponse,
        message: 'Unauthorized',
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = _TestHttpClientAdapter(error: dioException);
      final client = DioHttpClient(dio);

      expect(
        () => client.get<Map<String, dynamic>>('/users/1'),
        throwsA(
          isA<NetworkException>()
              .having((error) => error.statusCode, 'statusCode', 401)
              .having((error) => error.message, 'message', 'Unauthorized'),
        ),
      );
    });
  });
}
