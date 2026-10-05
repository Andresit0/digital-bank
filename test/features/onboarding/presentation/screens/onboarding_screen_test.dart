import 'package:digital_bank/features/onboarding/di/onboarding_providers.dart';
import 'package:digital_bank/features/onboarding/presentation/notifiers/onboarding_notifier.dart';
import 'package:digital_bank/features/onboarding/presentation/onboarding_state.dart';
import 'package:digital_bank/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fake_onboarding_repository.dart';

Future<ProviderContainer> _pump(
  WidgetTester tester,
  FakeOnboardingRepository repository,
) async {
  final container = ProviderContainer(
    overrides: [onboardingRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: OnboardingScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  group('OnboardingScreen', () {
    testWidgets('ONB-W-001 shows the first page', (tester) async {
      await _pump(tester, FakeOnboardingRepository());

      expect(find.text('Your money, in one place'), findsOneWidget);
      expect(find.text('Get started'), findsNothing);
    });

    testWidgets('ONB-W-002 Next advances to the next page', (tester) async {
      await _pump(tester, FakeOnboardingRepository());

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('A smarter experience'), findsOneWidget);
    });

    testWidgets('ONB-W-003 progresses through three pages', (tester) async {
      await _pump(tester, FakeOnboardingRepository());

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Stay informed'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);
    });

    testWidgets('ONB-W-004 Skip completes onboarding', (tester) async {
      final repository = FakeOnboardingRepository();
      final container = await _pump(tester, repository);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(repository.completeCalls, 1);
      expect(container.read(onboardingProvider), isA<OnboardingCompleted>());
    });

    testWidgets('ONB-W-005 Get started completes onboarding', (tester) async {
      final repository = FakeOnboardingRepository();
      final container = await _pump(tester, repository);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();

      expect(repository.completeCalls, 1);
      expect(container.read(onboardingProvider), isA<OnboardingCompleted>());
    });

    testWidgets('ONB-W-006 exposes semantic labels for primary controls', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();

      await _pump(tester, FakeOnboardingRepository());

      expect(find.bySemanticsLabel('Skip onboarding'), findsOneWidget);
      expect(find.bySemanticsLabel('Next onboarding step'), findsOneWidget);

      semantics.dispose();
    });
  });
}
