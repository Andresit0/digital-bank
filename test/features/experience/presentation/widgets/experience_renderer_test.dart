import 'package:digital_bank/features/experience/di/experience_providers.dart';
import 'package:digital_bank/features/experience/domain/entities/experience_definition.dart';
import 'package:digital_bank/features/experience/domain/entities/experience_section.dart';
import 'package:digital_bank/features/experience/domain/repositories/experience_repository.dart';
import 'package:digital_bank/features/experience/presentation/widgets/experience_renderer.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeExperienceRepository implements ExperienceRepository {
  _FakeExperienceRepository(this._result, {this.delay});

  final Result<ExperienceDefinition> _result;
  final Duration? delay;

  @override
  Future<Result<ExperienceDefinition>> fetchHomeExperience() async {
    if (delay != null) {
      await Future<void>.delayed(delay!);
    }
    return _result;
  }
}

Widget _wrap(
  Result<ExperienceDefinition> result, {
  ValueChanged<QuickActionType>? onAction,
  Duration? delay,
}) {
  return ProviderScope(
    overrides: [
      experienceRepositoryProvider.overrideWithValue(
        _FakeExperienceRepository(result, delay: delay),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(body: ExperienceRenderer(onAction: onAction ?? (_) {})),
    ),
  );
}

void main() {
  group('ExperienceRenderer', () {
    testWidgets('WID-EXP-001 shows loading', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Success(
            ExperienceDefinition(
              experience: 'account_home',
              version: 1,
              sections: [PromotionSection(title: 'Welcome')],
            ),
          ),
          delay: const Duration(seconds: 1),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('experience_loading')), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('WID-EXP-002 displays promotion and quick action', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const Success(
            ExperienceDefinition(
              experience: 'account_home',
              version: 1,
              sections: [
                PromotionSection(
                  title: 'Save more this month',
                  description: 'Discover our latest promotion',
                ),
                QuickActionSection(
                  label: 'View movements',
                  action: QuickActionType.viewMovements,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Save more this month'), findsOneWidget);
      expect(find.text('View movements'), findsOneWidget);
    });

    testWidgets('WID-EXP-003 shows fallback on empty', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Success(
            ExperienceDefinition(
              experience: 'account_home',
              version: 1,
              sections: [],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('experience_fallback')), findsOneWidget);
    });

    testWidgets('WID-EXP-004 shows fallback on failure', (tester) async {
      await tester.pumpWidget(
        _wrap(const Failure(NetworkError(technicalMessage: 'down'))),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('experience_fallback')), findsOneWidget);
    });

    testWidgets('WID-EXP-005 quick action expresses its intent', (
      tester,
    ) async {
      QuickActionType? received;
      await tester.pumpWidget(
        _wrap(
          const Success(
            ExperienceDefinition(
              experience: 'account_home',
              version: 1,
              sections: [
                QuickActionSection(
                  label: 'View movements',
                  action: QuickActionType.viewMovements,
                ),
              ],
            ),
          ),
          onAction: (action) => received = action,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('View movements'));
      await tester.pumpAndSettle();

      expect(received, QuickActionType.viewMovements);
    });
  });
}
