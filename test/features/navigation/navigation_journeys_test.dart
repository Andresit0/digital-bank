import 'package:digital_bank/app/router/app_router.dart';
import 'package:digital_bank/features/accounts/di/accounts_providers.dart';
import 'package:digital_bank/features/accounts/domain/entities/account.dart';
import 'package:digital_bank/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:digital_bank/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:digital_bank/features/experience/di/experience_providers.dart';
import 'package:digital_bank/features/experience/domain/entities/experience_definition.dart';
import 'package:digital_bank/features/experience/domain/entities/experience_section.dart';
import 'package:digital_bank/features/experience/domain/repositories/experience_repository.dart';
import 'package:digital_bank/features/home/presentation/screens/home_screen.dart';
import 'package:digital_bank/features/movements/di/movements_providers.dart';
import 'package:digital_bank/features/movements/domain/entities/movement.dart';
import 'package:digital_bank/features/movements/domain/repositories/movements_repository.dart';
import 'package:digital_bank/features/movements/presentation/screens/movement_detail_screen.dart';
import 'package:digital_bank/features/movements/presentation/screens/movements_screen.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/read.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _account = Account(
  id: 'acc-1',
  type: AccountType.savings,
  displayName: 'Savings Account',
  maskedNumber: '****1234',
  availableBalance: 1500.5,
);

final _movement = Movement(
  id: 'mov-1',
  accountId: 'acc-1',
  type: MovementType.credit,
  amount: 500,
  currency: 'USD',
  description: 'Salary',
  occurredAt: DateTime.utc(2026, 10, 1, 9, 30),
);

class _FakeAccountsRepository implements AccountsRepository {
  @override
  Future<Result<Read<List<Account>>>> fetchAccounts() async =>
      const Success<Read<List<Account>>>(
        Read<List<Account>>([_account], source: ReadSource.remote),
      );
}

class _FakeMovementsRepository implements MovementsRepository {
  @override
  Future<Result<Read<List<Movement>>>> fetchMovements({
    required String accountId,
  }) async => Success<Read<List<Movement>>>(
    Read<List<Movement>>([_movement], source: ReadSource.remote),
  );
}

class _FakeExperienceRepository implements ExperienceRepository {
  @override
  Future<Result<ExperienceDefinition>> fetchHomeExperience() async =>
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
              label: 'View accounts',
              action: QuickActionType.viewAccounts,
            ),
            QuickActionSection(
              label: 'View movements',
              action: QuickActionType.viewMovements,
            ),
          ],
        ),
      );
}

Widget _app(GoRouter router) {
  return ProviderScope(
    overrides: [
      accountsRepositoryProvider.overrideWithValue(_FakeAccountsRepository()),
      movementsRepositoryProvider.overrideWithValue(_FakeMovementsRepository()),
      experienceRepositoryProvider.overrideWithValue(
        _FakeExperienceRepository(),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

Future<GoRouter> _pumpHome(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = createAppRouter(initialLocation: AppRoute.home.path);
  await tester.pumpWidget(_app(router));
  await tester.pumpAndSettle();
  expect(find.byType(HomeScreen), findsOneWidget);
  return router;
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  group('Navigation journeys', () {
    testWidgets('NAV-001 Home -> My accounts -> back -> Home', (tester) async {
      final router = await _pumpHome(tester);

      await _tap(tester, find.text('My accounts'));

      expect(find.byType(AccountsScreen), findsOneWidget);
      expect(router.canPop(), isTrue);

      router.pop();
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(router.canPop(), isFalse);
    });

    testWidgets('NAV-002 Home -> View accounts -> back -> Home', (
      tester,
    ) async {
      final router = await _pumpHome(tester);

      await _tap(tester, find.text('View accounts'));

      expect(find.byType(AccountsScreen), findsOneWidget);
      expect(router.canPop(), isTrue);

      router.pop();
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets(
      'NAV-003 Home -> View movements -> select account -> movements -> back x2',
      (tester) async {
        final router = await _pumpHome(tester);

        await _tap(tester, find.text('View movements'));

        expect(find.text('Select an account'), findsOneWidget);

        await _tap(tester, find.byKey(const Key('account_card_acc-1')));

        expect(find.byType(MovementsScreen), findsOneWidget);

        router.pop();
        await tester.pumpAndSettle();
        expect(find.text('Select an account'), findsOneWidget);
        expect(find.byType(AccountsScreen), findsOneWidget);

        router.pop();
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(router.canPop(), isFalse);
      },
    );

    testWidgets('NAV-007 Home -> View accounts -> accounts (no selection)', (
      tester,
    ) async {
      final router = await _pumpHome(tester);

      await _tap(tester, find.text('View accounts'));

      expect(find.byType(AccountsScreen), findsOneWidget);
      expect(find.text('Select an account'), findsNothing);
      expect(router.canPop(), isTrue);
    });

    testWidgets('NAV-004 Accounts -> movements -> back -> Accounts', (
      tester,
    ) async {
      final router = await _pumpHome(tester);

      await _tap(tester, find.text('My accounts'));
      await _tap(tester, find.byKey(const Key('account_card_acc-1')));

      expect(find.byType(MovementsScreen), findsOneWidget);
      expect(router.canPop(), isTrue);

      router.pop();
      await tester.pumpAndSettle();

      expect(find.byType(AccountsScreen), findsOneWidget);
    });

    testWidgets('NAV-005 Movements -> movement -> back -> Movements', (
      tester,
    ) async {
      final router = await _pumpHome(tester);

      await _tap(tester, find.text('My accounts'));
      await _tap(tester, find.byKey(const Key('account_card_acc-1')));
      await _tap(tester, find.byKey(const Key('movement_tile_mov-1')));

      expect(find.byType(MovementDetailScreen), findsOneWidget);
      expect(router.canPop(), isTrue);

      router.pop();
      await tester.pumpAndSettle();

      expect(find.byType(MovementsScreen), findsOneWidget);
    });

    testWidgets(
      'NAV-006 Home -> accounts -> movements -> movement -> back x3 -> Home',
      (tester) async {
        final router = await _pumpHome(tester);

        await _tap(tester, find.text('My accounts'));
        await _tap(tester, find.byKey(const Key('account_card_acc-1')));
        await _tap(tester, find.byKey(const Key('movement_tile_mov-1')));

        expect(find.byType(MovementDetailScreen), findsOneWidget);

        router.pop();
        await tester.pumpAndSettle();
        expect(find.byType(MovementsScreen), findsOneWidget);

        router.pop();
        await tester.pumpAndSettle();
        expect(find.byType(AccountsScreen), findsOneWidget);

        router.pop();
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(router.canPop(), isFalse);
      },
    );
  });
}
