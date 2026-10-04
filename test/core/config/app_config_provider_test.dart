import 'package:digital_bank/core/config/app_config.dart';
import 'package:digital_bank/core/config/app_config_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('appConfigProvider', () {
    test('provides an AppConfig', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(appConfigProvider), isA<AppConfig>());
    });

    test('can be overridden in tests', () {
      final container = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(apiBaseUrl: 'https://override.test'),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(appConfigProvider).apiBaseUrl,
        'https://override.test',
      );
    });
  });
}
