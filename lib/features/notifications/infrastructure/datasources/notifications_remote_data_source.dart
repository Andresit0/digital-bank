import 'package:digital_bank/core/network/http_client.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/error/result_guard.dart';
import 'package:digital_bank/shared/exceptions/network_exception.dart';

abstract interface class NotificationsRemoteDataSource {
  Future<Result<void>> register({
    required String token,
    required String platform,
  });
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  NotificationsRemoteDataSourceImpl(this._httpClient);

  static const String _registerPath = '/notifications/register';

  final HttpClient _httpClient;

  @override
  Future<Result<void>> register({
    required String token,
    required String platform,
  }) {
    return guard(() async {
      final response = await _httpClient.post(
        _registerPath,
        data: {'token': token, 'platform': platform},
      );

      final statusCode = response.statusCode;
      if (statusCode == null || statusCode < 200 || statusCode >= 300) {
        throw NetworkException(
          message: 'device registration failed',
          statusCode: statusCode,
        );
      }
    });
  }
}
