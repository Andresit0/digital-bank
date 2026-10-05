import 'package:digital_bank/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';

class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository({
    this.completed = false,
    this.readFailure = false,
    this.writeFailure = false,
  });

  bool completed;
  final bool readFailure;
  final bool writeFailure;
  int completeCalls = 0;

  @override
  Future<Result<bool>> isCompleted() async {
    if (readFailure) {
      return const Failure<bool>(UnexpectedError());
    }
    return Success<bool>(completed);
  }

  @override
  Future<Result<void>> complete() async {
    completeCalls++;
    if (writeFailure) {
      return const Failure<void>(UnexpectedError());
    }
    completed = true;
    return const Success<void>(null);
  }
}
