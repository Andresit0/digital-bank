import 'package:digital_bank/core/network/http_client.dart';
import 'package:digital_bank/shared/exceptions/network_exception.dart';
import 'package:digital_bank/features/auth/infrastructure/datasources/auth_remote_data_source.dart';
import 'package:digital_bank/features/auth/infrastructure/models/auth_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHttpClient implements HttpClient {
  _FakeHttpClient(this._response);

  final HttpResponse<Map<String, dynamic>> _response;

  String? lastPath;
  Object? lastData;

  @override
  Future<HttpResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    lastPath = path;
    return HttpResponse<T>();
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    lastPath = path;
    lastData = data;
    return _response;
  }
}

void main() {
  group('AuthRemoteDataSource', () {
    test('delegates login to HttpClient and maps the response', () async {
      final httpClient = _FakeHttpClient(
        const HttpResponse(statusCode: 200, data: {'accessToken': 'token-123'}),
      );
      final dataSource = AuthRemoteDataSourceImpl(httpClient);

      final result = await dataSource.login(
        email: 'customer@example.com',
        password: 'secret',
      );

      expect(result, isA<AuthResponseModel>());
      expect(result.accessToken, 'token-123');
      expect(httpClient.lastPath, '/auth/login');
      expect(httpClient.lastData, {
        'email': 'customer@example.com',
        'password': 'secret',
      });
    });

    test('sends credentials through the HttpClient abstraction', () async {
      final httpClient = _FakeHttpClient(
        const HttpResponse(statusCode: 200, data: {'accessToken': 'abc'}),
      );
      final dataSource = AuthRemoteDataSourceImpl(httpClient);

      await dataSource.login(email: 'a@b.com', password: 'p');

      expect(httpClient.lastData, isNotNull);
    });

    test('throws NetworkException when the response body is missing', () async {
      final httpClient = _FakeHttpClient(const HttpResponse(statusCode: 200));
      final dataSource = AuthRemoteDataSourceImpl(httpClient);

      expect(
        () => dataSource.login(email: 'a@b.com', password: 'p'),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
