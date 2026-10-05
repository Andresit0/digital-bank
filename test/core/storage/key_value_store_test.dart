import 'dart:io';

import 'package:digital_bank/core/storage/key_value_store.dart';
import 'package:flutter_test/flutter_test.dart';

class _InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, bool> _data = {};

  @override
  Future<bool?> getBool(String key) async => _data[key];

  @override
  Future<void> setBool(String key, bool value) async {
    _data[key] = value;
  }
}

void main() {
  group('KeyValueStore contract', () {
    test('reads a stored bool value', () async {
      final KeyValueStore store = _InMemoryKeyValueStore();
      await store.setBool('flag', true);

      expect(await store.getBool('flag'), isTrue);
    });

    test('returns null for a missing key', () async {
      final KeyValueStore store = _InMemoryKeyValueStore();

      expect(await store.getBool('missing'), isNull);
    });

    test('writes a bool value', () async {
      final KeyValueStore store = _InMemoryKeyValueStore();

      await store.setBool('flag', false);

      expect(await store.getBool('flag'), isFalse);
    });

    test('STORAGE-ARCH-001 does not depend on the storage plugin', () {
      final source = File(
        'lib/core/storage/key_value_store.dart',
      ).readAsStringSync();

      expect(source.contains('shared_preferences'), isFalse);
    });
  });
}
