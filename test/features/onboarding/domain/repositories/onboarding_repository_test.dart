import 'package:digital_bank/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fake_onboarding_repository.dart';

void main() {
  group('OnboardingRepository contract', () {
    test('ONB-U-002 isCompleted returns Success(false) when not completed', () async {
      final OnboardingRepository repository = FakeOnboardingRepository();

      final result = await repository.isCompleted();

      expect(result, isA<Success<bool>>());
      expect((result as Success<bool>).data, isFalse);
    });

    test('ONB-U-001 isCompleted returns Success(true) when completed', () async {
      final OnboardingRepository repository = FakeOnboardingRepository(
        completed: true,
      );

      final result = await repository.isCompleted();

      expect((result as Success<bool>).data, isTrue);
    });

    test('ONB-U-007 isCompleted returns Failure when the store fails', () async {
      final OnboardingRepository repository = FakeOnboardingRepository(
        readFailure: true,
      );

      final result = await repository.isCompleted();

      expect(result, isA<Failure<bool>>());
    });

    test('ONB-U-003 complete returns Success(null) and persists completion', () async {
      final repository = FakeOnboardingRepository();

      final result = await repository.complete();

      expect(result, isA<Success<void>>());
      expect((await repository.isCompleted() as Success<bool>).data, isTrue);
    });

    test('ONB-U-007 complete returns Failure when the store fails', () async {
      final repository = FakeOnboardingRepository(writeFailure: true);

      final result = await repository.complete();

      expect(result, isA<Failure<void>>());
    });
  });
}
