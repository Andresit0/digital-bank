import 'package:flutter_test/flutter_test.dart';

import 'package:digital_bank/core/network/read_cache.dart';

void main() {
  group('ReadCache', () {
    test('RES-009 put then get returns the value', () {
      final cache = ReadCache();
      cache.put('accounts', 'value');
      expect(cache.get('accounts'), 'value');
    });

    test('RES-011 a missing key returns null', () {
      final cache = ReadCache();
      expect(cache.get('missing'), isNull);
    });

    test('RES-009 values are generic', () {
      final cache = ReadCache();
      cache.put('list', <String>['a', 'b']);
      cache.put('number', 42);
      cache.put('map', {'k': 'v'});

      expect(cache.get('list'), <String>['a', 'b']);
      expect(cache.get('number'), 42);
      expect(cache.get('map'), {'k': 'v'});
    });

    test('RES-012 replacing a key replaces its previous value', () {
      final cache = ReadCache();
      cache.put('accounts', 'old');
      cache.put('accounts', 'new');
      expect(cache.get('accounts'), 'new');
    });

    test('RES-009 independent keys remain independent', () {
      final cache = ReadCache();
      cache.put('accounts', 'a');
      cache.put('movements', 'm');
      expect(cache.get('accounts'), 'a');
      expect(cache.get('movements'), 'm');
    });

    test('RES-009 clear removes all entries', () {
      final cache = ReadCache();
      cache.put('accounts', 'a');
      cache.put('movements', 'm');
      cache.clear();
      expect(cache.get('accounts'), isNull);
      expect(cache.get('movements'), isNull);
    });

    test('RES-009 the cache has no TTL semantics', () {
      final cache = ReadCache();
      cache.put('accounts', 'a');
      expect(cache.get('accounts'), 'a');
      expect(cache.get('accounts'), 'a');
    });

    test('RES-009 the cache does not decide staleness', () {
      final cache = ReadCache();
      cache.put('accounts', 'cached');
      expect(cache.get('accounts'), 'cached');
    });
  });
}
