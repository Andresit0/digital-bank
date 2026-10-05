import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const String _plugin = 'package:shared_preferences';
const String _storageBoundary = 'lib/core/storage/';

List<File> _dartFiles(String directory) {
  return Directory(directory)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();
}

void main() {
  test('ONB-ARCH-001 features never import package:shared_preferences', () {
    for (final file in _dartFiles('lib/features')) {
      expect(
        file.readAsStringSync().contains(_plugin),
        isFalse,
        reason:
            '${file.path} must not depend on the storage plugin; '
            'only core/storage may',
      );
    }
  });

  test('ONB-ARCH-002 only core/storage imports package:shared_preferences', () {
    final importers = _dartFiles('lib')
        .where((file) => file.readAsStringSync().contains(_plugin))
        .map((file) => file.path);

    for (final path in importers) {
      expect(
        path.startsWith(_storageBoundary),
        isTrue,
        reason: '$path imports $_plugin outside $_storageBoundary',
      );
    }
  });
}
