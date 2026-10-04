import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class ApiTestRequest {
  const ApiTestRequest({
    required this.method,
    required this.path,
    required this.body,
  });

  final String method;
  final String path;
  final Map<String, dynamic> body;
}

enum ApiTestBehavior { success, serverError, closeConnection }

class ApiTestServer implements HttpClientAdapter {
  ApiTestServer._({
    required this.behavior,
    required this.statusCode,
    required this.responseData,
  });

  factory ApiTestServer.success(Object? data, {int statusCode = 200}) {
    return ApiTestServer._(
      behavior: ApiTestBehavior.success,
      statusCode: statusCode,
      responseData: data,
    );
  }

  factory ApiTestServer.unauthorized({Object? data}) {
    return ApiTestServer._(
      behavior: ApiTestBehavior.success,
      statusCode: 401,
      responseData: data ?? {'message': 'Unauthorized'},
    );
  }

  factory ApiTestServer.serverError() {
    return ApiTestServer._(
      behavior: ApiTestBehavior.serverError,
      statusCode: 500,
      responseData: {'message': 'Internal Server Error'},
    );
  }

  factory ApiTestServer.closeConnection() {
    return ApiTestServer._(
      behavior: ApiTestBehavior.closeConnection,
      statusCode: 200,
      responseData: null,
    );
  }

  final ApiTestBehavior behavior;
  final int statusCode;
  final Object? responseData;
  final List<ApiTestRequest> requests = [];

  ApiTestRequest? get lastRequest => requests.isEmpty ? null : requests.last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(
      ApiTestRequest(
        method: options.method,
        path: options.path,
        body: Map<String, dynamic>.from(options.data as Map? ?? const {}),
      ),
    );

    switch (behavior) {
      case ApiTestBehavior.closeConnection:
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'connection failed',
        );
      case ApiTestBehavior.serverError:
        return ResponseBody.fromString(
          jsonEncode(responseData),
          statusCode,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      case ApiTestBehavior.success:
        return ResponseBody.fromString(
          jsonEncode(responseData),
          statusCode,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
    }
  }

  @override
  void close({bool force = false}) {}
}
