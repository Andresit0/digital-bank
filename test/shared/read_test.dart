import 'package:flutter_test/flutter_test.dart';

import 'package:digital_bank/shared/read.dart';

void main() {
  group('Read', () {
    test('RES-009 Read preserves the supplied data', () {
      const read = Read<String>('payload', source: ReadSource.remote);
      expect(read.data, 'payload');
    });

    test('RES-009 ReadSource.remote identifies fresh remote data', () {
      const read = Read<int>(1, source: ReadSource.remote);
      expect(read.source, ReadSource.remote);
    });

    test('RES-010 ReadSource.cache identifies stale cached data', () {
      const read = Read<int>(1, source: ReadSource.cache);
      expect(read.source, ReadSource.cache);
    });

    test('RES-009 generic types are supported', () {
      const read = Read<List<String>>(['a', 'b'], source: ReadSource.remote);
      expect(read.data, <String>['a', 'b']);
    });

    test('RES-009 the source is explicit and immutable', () {
      const read = Read<String>('x', source: ReadSource.cache);
      expect(read.source, ReadSource.cache);
      expect(read.data, 'x');
    });
  });
}
