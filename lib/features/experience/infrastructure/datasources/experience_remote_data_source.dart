import 'package:digital_bank/core/network/http_client.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/error/result_guard.dart';
import 'package:digital_bank/shared/exceptions/network_exception.dart';

import '../models/experience_definition_model.dart';

abstract interface class ExperienceRemoteDataSource {
  Future<Result<ExperienceDefinitionModel>> fetchHomeExperience();
}

class ExperienceRemoteDataSourceImpl implements ExperienceRemoteDataSource {
  ExperienceRemoteDataSourceImpl(this._httpClient);

  static const String _homeExperiencePath = '/experience/home';

  final HttpClient _httpClient;

  @override
  Future<Result<ExperienceDefinitionModel>> fetchHomeExperience() {
    return guard(() async {
      final response = await _httpClient.get<Map<String, dynamic>>(
        _homeExperiencePath,
      );

      final data = response.data;
      if (data == null) {
        throw NetworkException(
          message: 'empty response body',
          statusCode: response.statusCode,
        );
      }

      return ExperienceDefinitionModel.fromJson(data);
    });
  }
}
