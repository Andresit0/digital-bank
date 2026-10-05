import 'package:digital_bank/core/session/session_manager.dart';
import 'package:digital_bank/core/session/session_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sessionManagerProvider', () {
    test('SES-010 resolves a SessionManager', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(sessionManagerProvider), isA<SessionManager>());
    });

    test('SES-011 exposes a shared instance within the container', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final first = container.read(sessionManagerProvider);
      final second = container.read(sessionManagerProvider);

      expect(identical(first, second), isTrue);
    });
  });
}
