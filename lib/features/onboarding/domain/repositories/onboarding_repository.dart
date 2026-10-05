import 'package:digital_bank/shared/error/result.dart';

abstract interface class OnboardingRepository {
  Future<Result<bool>> isCompleted();

  Future<Result<void>> complete();
}
