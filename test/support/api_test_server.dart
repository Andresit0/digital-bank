import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class ApiTestRequest {
  const ApiTestRequest({
    required this.method,
    required this.path,
    required this.body,
    this.authorization,
  });

  final String method;
  final String path;
  final Map<String, dynamic> body;
  final String? authorization;
}

enum ApiTestBehavior { success, serverError, closeConnection }

class ApiTestServer implements HttpClientAdapter {
  ApiTestServer._({
    required this.behavior,
    required this.statusCode,
    required this.responseData,
    this.requiredBearer,
    this.routes,
  });

  factory ApiTestServer.success(Object? data, {int statusCode = 200}) {
    return ApiTestServer._(
      behavior: ApiTestBehavior.success,
      statusCode: statusCode,
      responseData: data,
    );
  }

  factory ApiTestServer.protected(
    Object? data, {
    required String requiredBearer,
    int statusCode = 200,
  }) {
    return ApiTestServer._(
      behavior: ApiTestBehavior.success,
      statusCode: statusCode,
      responseData: data,
      requiredBearer: requiredBearer,
    );
  }

  factory ApiTestServer.routed({
    required Map<String, Object?> routes,
    required String requiredBearer,
    int statusCode = 200,
  }) {
    return ApiTestServer._(
      behavior: ApiTestBehavior.success,
      statusCode: statusCode,
      responseData: null,
      requiredBearer: requiredBearer,
      routes: routes,
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
  final String? requiredBearer;
  final Map<String, Object?>? routes;
  final List<ApiTestRequest> requests = [];

  ApiTestRequest? get lastRequest => requests.isEmpty ? null : requests.last;

  ApiTestRequest? requestFor(String path) {
    for (final request in requests.reversed) {
      if (request.path == path) return request;
    }
    return null;
  }

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
        authorization: options.headers['Authorization'] as String?,
      ),
    );

    if (requiredBearer != null &&
        options.headers['Authorization'] != 'Bearer $requiredBearer') {
      return ResponseBody.fromString(
        jsonEncode({'message': 'Unauthorized'}),
        401,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

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
        final data = routes?[options.path] ?? responseData;
        return ResponseBody.fromString(
          jsonEncode(data),
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
