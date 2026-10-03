import 'package:digital_bank/app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starts on the bootstrap route', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: createAppRouter()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Application Bootstrap'), findsOneWidget);
  });

  testWidgets('navigates to the home route', (tester) async {
    final router = createAppRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    router.go(AppRoute.home.path);
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });
}
