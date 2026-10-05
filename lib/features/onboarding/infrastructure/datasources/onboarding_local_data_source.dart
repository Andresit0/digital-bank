import 'package:digital_bank/core/storage/key_value_store.dart';

abstract interface class OnboardingLocalDataSource {
  Future<bool> isCompleted();

  Future<void> markCompleted();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  OnboardingLocalDataSourceImpl(this._store);

  static const String _completedKey = 'onboarding_completed';

  final KeyValueStore _store;

  @override
  Future<bool> isCompleted() async {
    final value = await _store.getBool(_completedKey);
    return value ?? false;
  }

  @override
  Future<void> markCompleted() => _store.setBool(_completedKey, true);
}
