import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/error/result_guard.dart';

import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._localDataSource);

  final OnboardingLocalDataSource _localDataSource;

  @override
  Future<Result<bool>> isCompleted() => guard(_localDataSource.isCompleted);

  @override
  Future<Result<void>> complete() => guard(() async {
    await _localDataSource.markCompleted();
  });
}
