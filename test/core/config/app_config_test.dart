import 'package:digital_bank/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test('exposes the api base url', () {
      const config = AppConfig(apiBaseUrl: 'https://api.example.test');

      expect(config.apiBaseUrl, 'https://api.example.test');
    });

    test('supports value equality', () {
      const a = AppConfig(apiBaseUrl: 'https://api.example.test');
      const b = AppConfig(apiBaseUrl: 'https://api.example.test');

      expect(a, equals(b));
    });
  });
}
