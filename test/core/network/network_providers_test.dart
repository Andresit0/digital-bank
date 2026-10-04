import 'package:digital_bank/core/config/app_config.dart';
import 'package:digital_bank/core/config/app_config_provider.dart';
import 'package:digital_bank/core/network/dio_http_client.dart';
import 'package:digital_bank/core/network/http_client.dart';
import 'package:digital_bank/core/network/network_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHttpClient implements HttpClient {
  @override
  Future<HttpResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return HttpResponse<T>();
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

  test('dioProvider uses AppConfig.apiBaseUrl as baseUrl', () {
    final container = ProviderContainer(
      overrides: [
        appConfigProvider.overrideWithValue(
          const AppConfig(apiBaseUrl: 'https://api.example.test'),
        ),
      ],
    );
    addTearDown(container.dispose);

    final dio = container.read(dioProvider);
    expect(dio.options.baseUrl, 'https://api.example.test');
  });

  test('dioProvider preserves the PR8 timeouts', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final options = container.read(dioProvider).options;
    expect(options.connectTimeout, const Duration(seconds: 10));
    expect(options.receiveTimeout, const Duration(seconds: 10));
    expect(options.sendTimeout, const Duration(seconds: 10));
  });
}
