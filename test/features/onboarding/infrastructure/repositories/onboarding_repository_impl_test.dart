import 'package:digital_bank/features/onboarding/infrastructure/datasources/onboarding_local_data_source.dart';
import 'package:digital_bank/features/onboarding/infrastructure/repositories/onboarding_repository_impl.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOnboardingLocalDataSource implements OnboardingLocalDataSource {
  _FakeOnboardingLocalDataSource({
    this.completed = false,
    this.readFailure = false,
    this.writeFailure = false,
  });

  bool completed;
  final bool readFailure;
  final bool writeFailure;
  int markCompletedCalls = 0;

  @override
  Future<bool> isCompleted() async {
    if (readFailure) {
      throw Exception('read failure');
    }
    return completed;
  }

  @override
  Future<void> markCompleted() async {
    markCompletedCalls++;
    if (writeFailure) {
      throw Exception('write failure');
    }
    completed = true;
  }
}

void main() {
  group('OnboardingRepositoryImpl', () {
    test('ONB-U-001 isCompleted returns Success(true) when completed', () async {
      final repository = OnboardingRepositoryImpl(
        _FakeOnboardingLocalDataSource(completed: true),
      );

      final result = await repository.isCompleted();

      expect(result, isA<Success<bool>>());
      expect((result as Success<bool>).data, isTrue);
    });

    test('ONB-U-002 isCompleted returns Success(false) when not completed', () async {
      final repository = OnboardingRepositoryImpl(
        _FakeOnboardingLocalDataSource(),
      );

      final result = await repository.isCompleted();

      expect((result as Success<bool>).data, isFalse);
    });

    test('ONB-U-007 a read failure returns Failure(AppError)', () async {
      final repository = OnboardingRepositoryImpl(
        _FakeOnboardingLocalDataSource(readFailure: true),
      );

      final result = await repository.isCompleted();

      expect(result, isA<Failure<bool>>());
      expect((result as Failure<bool>).error, isA<AppError>());
    });

    test('ONB-U-003 complete returns Success(null) and persists completion', () async {
      final dataSource = _FakeOnboardingLocalDataSource();
      final repository = OnboardingRepositoryImpl(dataSource);

      final result = await repository.complete();

      expect(result, isA<Success<void>>());
      expect(dataSource.markCompletedCalls, 1);
    });

    test('ONB-U-007 a write failure returns Failure(AppError)', () async {
      final repository = OnboardingRepositoryImpl(
        _FakeOnboardingLocalDataSource(writeFailure: true),
      );

      final result = await repository.complete();

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, isA<AppError>());
    });
  });
}
