import 'package:dio/dio.dart';
import 'package:digital_bank/core/network/dio_http_client.dart';
import 'package:digital_bank/features/notifications/infrastructure/datasources/notifications_remote_data_source.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/api_test_server.dart';

NotificationsRemoteDataSourceImpl _dataSourceFor(ApiTestServer server) {
  final dio = Dio(BaseOptions(baseUrl: 'http://api.test'))
    ..httpClientAdapter = server;
  return NotificationsRemoteDataSourceImpl(DioHttpClient(dio));
}

void main() {
  group('NotificationsRemoteDataSource', () {
    test('API-NTF-002 registers the token and platform', () async {
      final server = ApiTestServer.success({'id': 'inst-1'});
      final dataSource = _dataSourceFor(server);

      final result = await dataSource.register(
        token: 'fake-fcm-registration-token',
        platform: 'android',
      );

      expect(result, isA<Success<void>>());
      final request = server.requestFor('/notifications/register');
      expect(request?.method, 'POST');
      expect(request?.body['token'], 'fake-fcm-registration-token');
      expect(request?.body['platform'], 'android');
    });

    test('maps a 401 to ApiError(401)', () async {
      final server = ApiTestServer.unauthorized();
      final dataSource = _dataSourceFor(server);

      final result = await dataSource.register(
        token: 'token-a',
        platform: 'android',
      );

      expect(result, isA<Failure<void>>());
      final error = (result as Failure<void>).error;
      expect(error, isA<ApiError>());
      expect((error as ApiError).statusCode, 401);
    });

    test('maps a transport failure to NetworkError', () async {
      final server = ApiTestServer.closeConnection();
      final dataSource = _dataSourceFor(server);

      final result = await dataSource.register(
        token: 'token-a',
        platform: 'android',
      );

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, isA<NetworkError>());
    });
  });
}
