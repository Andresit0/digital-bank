import 'package:dio/dio.dart';
import 'package:digital_bank/core/network/dio_http_client.dart';
import 'package:digital_bank/features/experience/domain/entities/experience_definition.dart';
import 'package:digital_bank/features/experience/domain/entities/experience_section.dart';
import 'package:digital_bank/features/experience/infrastructure/datasources/experience_remote_data_source.dart';
import 'package:digital_bank/features/experience/infrastructure/repositories/experience_repository_impl.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/api_test_server.dart';

ExperienceRepositoryImpl _repositoryFor(ApiTestServer server) {
  final dio = Dio(BaseOptions(baseUrl: 'http://api.test'))
    ..httpClientAdapter = server;
  final httpClient = DioHttpClient(dio);
  final dataSource = ExperienceRemoteDataSourceImpl(httpClient);
  return ExperienceRepositoryImpl(dataSource);
}

void main() {
  group('Experience integration flow', () {
    test('INT-EXP-001 loads an experience with sections', () async {
      final server = ApiTestServer.success({
        'experience': 'account_home',
        'version': 3,
        'sections': [
          {
            'type': 'promotion',
            'title': 'Save more this month',
            'description': 'Discover our latest promotion',
          },
          {
            'type': 'quick_action',
            'label': 'View movements',
            'action': 'view_movements',
          },
        ],
      });

      final result = await _repositoryFor(server).fetchHomeExperience();

      expect(server.lastRequest?.method, 'GET');
      expect(server.lastRequest?.path, '/experience/home');
      expect(result, isA<Success<ExperienceDefinition>>());
      result.when(
        success: (definition) {
          expect(definition.sections, hasLength(2));
          expect(definition.sections.first, isA<PromotionSection>());
          expect(definition.sections.last, isA<QuickActionSection>());
        },
        failure: (_) => fail('expected success'),
      );
    });

    test('INT-EXP-002 yields an empty definition', () async {
      final server = ApiTestServer.success({
        'experience': 'account_home',
        'version': 1,
        'sections': <dynamic>[],
      });

      final result = await _repositoryFor(server).fetchHomeExperience();

      result.when(
        success: (definition) => expect(definition.sections, isEmpty),
        failure: (_) => fail('expected success'),
      );
    });

    test('maps an invalid schema to Failure(UnexpectedError)', () async {
      final server = ApiTestServer.success({
        'experience': 'account_home',
        'version': 1,
        'sections': [
          {'type': 'quick_action', 'label': 'Delete', 'action': 'delete'},
        ],
      });

      final result = await _repositoryFor(server).fetchHomeExperience();

      expect(result, isA<Failure<ExperienceDefinition>>());
      result.when(
        success: (_) => fail('expected failure'),
        failure: (error) => expect(error, isA<UnexpectedError>()),
      );
    });

    test('maps a 5xx to Failure(ApiError)', () async {
      final server = ApiTestServer.serverError();

      final result = await _repositoryFor(server).fetchHomeExperience();

      result.when(
        success: (_) => fail('expected failure'),
        failure: (error) => expect(error, isA<ApiError>()),
      );
    });

    test('maps a transport failure to Failure(NetworkError)', () async {
      final server = ApiTestServer.closeConnection();

      final result = await _repositoryFor(server).fetchHomeExperience();

      result.when(
        success: (_) => fail('expected failure'),
        failure: (error) => expect(error, isA<NetworkError>()),
      );
    });
  });
}
