import 'package:digital_bank/app/app.dart';
import 'package:digital_bank/app/di/router/router_provider.dart';
import 'package:digital_bank/app/router/app_router.dart';
import 'package:digital_bank/features/auth/presentation/screens/login_screen.dart';
import 'package:digital_bank/features/onboarding/di/onboarding_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_onboarding_repository.dart';

void main() {
  testWidgets('redirects to login when unauthenticated', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(
            FakeOnboardingRepository(completed: true),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('consumes the router provided by the composition root', (
    tester,
  ) async {
    final overrideRouter = createAppRouter(initialLocation: AppRoute.home.path);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          goRouterProvider.overrideWithValue(overrideRouter),
          onboardingRepositoryProvider.overrideWithValue(
            FakeOnboardingRepository(completed: true),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });
}
