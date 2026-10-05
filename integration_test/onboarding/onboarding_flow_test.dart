import 'package:digital_bank/app/app.dart';
import 'package:digital_bank/features/auth/presentation/screens/login_screen.dart';
import 'package:digital_bank/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../support/onboarding_test_support.dart';

Future<void> _pumpApp(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MyApp()),
  );
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E-ONB-001 onboarding is required then persisted', (
    tester,
  ) async {
    await clearOnboardingCompleted();

    final firstContainer = ProviderContainer();
    addTearDown(firstContainer.dispose);
    await _pumpApp(tester, firstContainer);

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(await onboardingCompleted(), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    final secondContainer = ProviderContainer();
    addTearDown(secondContainer.dispose);
    await _pumpApp(tester, secondContainer);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
  });
}
