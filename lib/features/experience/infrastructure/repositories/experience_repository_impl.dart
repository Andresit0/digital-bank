import 'package:digital_bank/shared/error/result.dart';

import '../../domain/entities/experience_definition.dart';
import '../../domain/entities/experience_section.dart';
import '../../domain/repositories/experience_repository.dart';
import '../datasources/experience_remote_data_source.dart';
import '../models/experience_definition_model.dart';
import '../models/experience_section_model.dart';

class ExperienceRepositoryImpl implements ExperienceRepository {
  ExperienceRepositoryImpl(this._remoteDataSource);

  final ExperienceRemoteDataSource _remoteDataSource;

  @override
  Future<Result<ExperienceDefinition>> fetchHomeExperience() async {
    final result = await _remoteDataSource.fetchHomeExperience();
    return result.when(
      success: (model) => Success(_toEntity(model)),
      failure: (error) => Failure(error),
    );
  }

  ExperienceDefinition _toEntity(ExperienceDefinitionModel model) {
    return ExperienceDefinition(
      experience: model.experience,
      version: model.version,
      sections: model.sections.map(_toSection).toList(),
    );
  }

  ExperienceSection _toSection(ExperienceSectionModel model) {
    if (model.type == 'quick_action') {
      return QuickActionSection(
        label: model.label!,
        action: _toAction(model.action!),
      );
    }
    return PromotionSection(
      title: model.title!,
      description: model.description,
    );
  }

  QuickActionType _toAction(String action) {
    switch (action) {
      case 'view_movements':
        return QuickActionType.viewMovements;
      case 'view_accounts':
        return QuickActionType.viewAccounts;
      default:
        throw FormatException('unsupported quick action: $action');
    }
  }
}
