import 'package:flutter/foundation.dart' show immutable;

@immutable
class HttpResponse<T> {
  const HttpResponse({this.data, this.statusCode});

  final T? data;
  final int? statusCode;
}

abstract interface class HttpClient {
  Future<HttpResponse<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  });

  Future<HttpResponse<Map<String, dynamic>>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  });
}
