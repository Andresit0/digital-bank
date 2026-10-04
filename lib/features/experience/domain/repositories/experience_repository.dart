import 'package:digital_bank/shared/error/result.dart';

import '../entities/experience_definition.dart';

abstract interface class ExperienceRepository {
  Future<Result<ExperienceDefinition>> fetchHomeExperience();
}
