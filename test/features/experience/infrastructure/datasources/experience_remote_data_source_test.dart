import 'package:digital_bank/core/network/http_client.dart';
import 'package:digital_bank/features/experience/infrastructure/datasources/experience_remote_data_source.dart';
import 'package:digital_bank/features/experience/infrastructure/models/experience_definition_model.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/exceptions/network_exception.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHttpClient implements HttpClient {
  _FakeHttpClient({this.response, this.error});

  final HttpResponse<Map<String, dynamic>>? response;
  final Object? error;

  String? lastPath;

  @override
  Future<HttpResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    lastPath = path;
    if (error != null) {
      throw error!;
    }
    return response as HttpResponse<T>;
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
  group('ExperienceRemoteDataSource', () {
    test('fetches the definition through HttpClient', () async {
      final httpClient = _FakeHttpClient(
        response: const HttpResponse(
          statusCode: 200,
          data: {
            'experience': 'account_home',
            'version': 3,
            'sections': [
              {'type': 'promotion', 'title': 'Save more this month'},
            ],
          },
        ),
      );
      final dataSource = ExperienceRemoteDataSourceImpl(httpClient);

      final result = await dataSource.fetchHomeExperience();

      expect(httpClient.lastPath, '/experience/home');
      result.when(
        success: (model) => expect(model, isA<ExperienceDefinitionModel>()),
        failure: (_) => fail('expected success'),
      );
    });

    test('maps a transport failure to Failure(NetworkError)', () async {
      final httpClient = _FakeHttpClient(
        error: const NetworkException(message: 'connection failed'),
      );
      final dataSource = ExperienceRemoteDataSourceImpl(httpClient);

      final result = await dataSource.fetchHomeExperience();

      expect(result, isA<Failure<ExperienceDefinitionModel>>());
      result.when(
        success: (_) => fail('expected failure'),
        failure: (error) => expect(error, isA<NetworkError>()),
      );
    });

    test('maps an invalid payload to Failure(UnexpectedError)', () async {
      final httpClient = _FakeHttpClient(
        response: const HttpResponse(
          statusCode: 200,
          data: {'experience': 'account_home'},
        ),
      );
      final dataSource = ExperienceRemoteDataSourceImpl(httpClient);

      final result = await dataSource.fetchHomeExperience();

      expect(result, isA<Failure<ExperienceDefinitionModel>>());
      result.when(
        success: (_) => fail('expected failure'),
        failure: (error) => expect(error, isA<UnexpectedError>()),
      );
    });
  });
}
