import 'package:digital_bank/core/network/http_client.dart';
import 'package:digital_bank/features/movements/infrastructure/datasources/movements_remote_data_source.dart';
import 'package:digital_bank/features/movements/infrastructure/models/movement_model.dart';
import 'package:digital_bank/shared/exceptions/network_exception.dart';
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
  group('MovementsRemoteDataSource', () {
    test('requests the account path and maps each item', () async {
      final httpClient = _FakeHttpClient(
        const HttpResponse(
          statusCode: 200,
          data: [
            {
              'id': 'mov-1',
              'accountId': 'acc-1',
              'type': 'credit',
              'amount': 100.0,
              'currency': 'USD',
              'description': 'ignored',
              'occurredAt': '2026-10-01T09:30:00.000Z',
            },
          ],
        ),
      );
      final dataSource = MovementsRemoteDataSourceImpl(httpClient);

      final result = await dataSource.fetchMovements(accountId: 'acc-1');

      expect(httpClient.lastPath, '/accounts/acc-1/movements');
      expect(result, hasLength(1));
      expect(result.first, isA<MovementModel>());
      expect(result.first.accountId, 'acc-1');
    });

    test('returns an empty list when the response is empty', () async {
      final httpClient = _FakeHttpClient(
        const HttpResponse(statusCode: 200, data: <dynamic>[]),
      );
      final dataSource = MovementsRemoteDataSourceImpl(httpClient);

      final result = await dataSource.fetchMovements(accountId: 'acc-1');

      expect(result, isEmpty);
    });

    test('throws NetworkException when the response body is missing', () async {
      final httpClient = _FakeHttpClient(const HttpResponse(statusCode: 200));
      final dataSource = MovementsRemoteDataSourceImpl(httpClient);

      expect(
        () => dataSource.fetchMovements(accountId: 'acc-1'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('throws NetworkException for an invalid payload', () async {
      final httpClient = _FakeHttpClient(
        const HttpResponse(
          statusCode: 200,
          data: [
            {
              'id': 'mov-1',
              'accountId': 'acc-1',
              'type': 'unknown',
              'amount': 100.0,
              'currency': 'USD',
              'description': 'x',
              'occurredAt': '2026-10-01T09:30:00.000Z',
            },
          ],
        ),
      );
      final dataSource = MovementsRemoteDataSourceImpl(httpClient);

      expect(
        () => dataSource.fetchMovements(accountId: 'acc-1'),
        throwsA(
          isA<NetworkException>().having(
            (error) => error.message,
            'message',
            'invalid movements payload',
          ),
        ),
      );
    });
  });
}
