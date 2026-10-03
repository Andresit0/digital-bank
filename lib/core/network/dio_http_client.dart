import 'package:dio/dio.dart';

import 'http_client.dart';
import 'network_exception.dart';

class DioHttpClient implements HttpClient {
  DioHttpClient(this._dio);

  final Dio _dio;

  @override
  Future<HttpResponse<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return HttpResponse(data: response.data, statusCode: response.statusCode);
    } on DioException catch (error) {
      throw NetworkException(
        message: error.message ?? 'network error',
        statusCode: error.response?.statusCode,
      );
    }
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return HttpResponse(data: response.data, statusCode: response.statusCode);
    } on DioException catch (error) {
      throw NetworkException(
        message: error.message ?? 'network error',
        statusCode: error.response?.statusCode,
      );
    }
  }
}
