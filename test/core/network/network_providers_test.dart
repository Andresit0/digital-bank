import 'package:digital_bank/core/network/dio_http_client.dart';
import 'package:digital_bank/core/network/http_client.dart';
import 'package:digital_bank/core/network/network_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHttpClient implements HttpClient {
  @override
  Future<HttpResponse<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return const HttpResponse(statusCode: 200);
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return const HttpResponse(statusCode: 200);
  }
}

void main() {
  test('provides a DioHttpClient by default', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(httpClientProvider), isA<DioHttpClient>());
  });

  test('can be overridden in tests', () {
    final container = ProviderContainer(
      overrides: [httpClientProvider.overrideWithValue(_FakeHttpClient())],
    );
    addTearDown(container.dispose);

    expect(container.read(httpClientProvider), isA<_FakeHttpClient>());
  });
}
