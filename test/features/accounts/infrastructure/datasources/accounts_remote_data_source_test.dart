import 'package:digital_bank/core/network/http_client.dart';
import 'package:digital_bank/features/accounts/infrastructure/datasources/accounts_remote_data_source.dart';
import 'package:digital_bank/features/accounts/infrastructure/models/account_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHttpClient implements HttpClient {
  _FakeHttpClient(this._listResponse);

  final HttpResponse<List<dynamic>> _listResponse;

  String? lastPath;

  @override
  Future<HttpResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    lastPath = path;
    return _listResponse as HttpResponse<T>;
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return const HttpResponse();
  }
}

void main() {
  group('AccountsRemoteDataSource', () {
    test('fetches accounts through HttpClient and maps each item', () async {
      final httpClient = _FakeHttpClient(
        const HttpResponse(
          statusCode: 200,
          data: [
            {
              'id': 'acc-1',
              'type': 'savings',
              'displayName': 'Savings Account',
              'maskedNumber': '****1234',
              'availableBalance': 1500.5,
            },
          ],
        ),
      );
      final dataSource = AccountsRemoteDataSourceImpl(httpClient);

      final result = await dataSource.fetchAccounts();

      expect(httpClient.lastPath, '/accounts');
      expect(result, hasLength(1));
      expect(result.first, isA<AccountModel>());
      expect(result.first.id, 'acc-1');
    });

    test('returns an empty list when the response is empty', () async {
      final httpClient = _FakeHttpClient(
        const HttpResponse(statusCode: 200, data: <dynamic>[]),
      );
      final dataSource = AccountsRemoteDataSourceImpl(httpClient);

      final result = await dataSource.fetchAccounts();

      expect(result, isEmpty);
    });
  });
}
