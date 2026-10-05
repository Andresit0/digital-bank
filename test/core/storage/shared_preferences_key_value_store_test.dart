import 'package:digital_bank/core/storage/shared_preferences_key_value_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('SharedPreferencesKeyValueStore', () {
    test('reads a stored bool value', () async {
      final store = SharedPreferencesKeyValueStore();
      await store.setBool('onboarding_completed', true);

      expect(await store.getBool('onboarding_completed'), isTrue);
    });

    test('returns null for a missing key', () async {
      final store = SharedPreferencesKeyValueStore();

      expect(await store.getBool('missing'), isNull);
    });

    test('writes a bool value', () async {
      final store = SharedPreferencesKeyValueStore();

      await store.setBool('flag', false);

      expect(await store.getBool('flag'), isFalse);
    });

    test('delegates to SharedPreferencesAsync', () async {
      final store = SharedPreferencesKeyValueStore();
      await store.setBool('flag', true);

      final other = SharedPreferencesKeyValueStore();

      expect(await other.getBool('flag'), isTrue);
    });
  });
}
