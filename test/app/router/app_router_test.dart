import 'package:digital_bank/app/router/app_router.dart';
import 'package:digital_bank/features/experience/di/experience_providers.dart';
import 'package:digital_bank/features/experience/domain/entities/experience_definition.dart';
import 'package:digital_bank/features/experience/domain/repositories/experience_repository.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeExperienceRepository implements ExperienceRepository {
  @override
  Future<Result<ExperienceDefinition>> fetchHomeExperience() async {
    return const Success(
      ExperienceDefinition(
        experience: 'account_home',
        version: 1,
        sections: [],
      ),
    );
  }
}

Widget _app(GoRouter router) {
  return ProviderScope(
    overrides: [
      experienceRepositoryProvider.overrideWithValue(
        _FakeExperienceRepository(),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('starts on the bootstrap route', (tester) async {
    await tester.pumpWidget(_app(createAppRouter()));
    await tester.pumpAndSettle();

    expect(find.text('Application Bootstrap'), findsOneWidget);
  });

  testWidgets('navigates to the home route', (tester) async {
    final router = createAppRouter();
    await tester.pumpWidget(_app(router));
    await tester.pumpAndSettle();

    router.go(AppRoute.home.path);
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });
}
