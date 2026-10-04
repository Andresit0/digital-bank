import 'package:digital_bank/app/app.dart';
import 'package:digital_bank/app/di/router/router_provider.dart';
import 'package:digital_bank/app/router/app_router.dart';
import 'package:digital_bank/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('redirects to login when unauthenticated', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('consumes the router provided by the composition root', (
    tester,
  ) async {
    final overrideRouter = createAppRouter(initialLocation: AppRoute.home.path);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [goRouterProvider.overrideWithValue(overrideRouter)],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });
}
