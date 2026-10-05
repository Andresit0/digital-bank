import 'package:digital_bank/core/storage/key_value_store.dart';
import 'package:digital_bank/features/onboarding/infrastructure/datasources/onboarding_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeKeyValueStore implements KeyValueStore {
  _FakeKeyValueStore([this.value]);

  bool? value;
  final Map<String, bool> writes = {};

  @override
  Future<bool?> getBool(String key) async => value;

  @override
  Future<void> setBool(String key, bool value) async {
    writes[key] = value;
    this.value = value;
  }
}

void main() {
  group('OnboardingLocalDataSource', () {
    test('ONB-U-004 returns false when the key is absent', () async {
      final dataSource = OnboardingLocalDataSourceImpl(_FakeKeyValueStore());

      expect(await dataSource.isCompleted(), isFalse);
    });

    test('returns false when the stored value is false', () async {
      final dataSource = OnboardingLocalDataSourceImpl(
        _FakeKeyValueStore(false),
      );

      expect(await dataSource.isCompleted(), isFalse);
    });

    test('returns true when the stored value is true', () async {
      final dataSource = OnboardingLocalDataSourceImpl(
        _FakeKeyValueStore(true),
      );

      expect(await dataSource.isCompleted(), isTrue);
    });

    test('ONB-U-003 markCompleted persists true under onboarding_completed', () async {
      final store = _FakeKeyValueStore();
      final dataSource = OnboardingLocalDataSourceImpl(store);

      await dataSource.markCompleted();

      expect(store.writes['onboarding_completed'], isTrue);
    });
  });
}
