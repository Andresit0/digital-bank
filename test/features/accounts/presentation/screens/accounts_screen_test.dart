import 'package:digital_bank/features/accounts/di/accounts_providers.dart';
import 'package:digital_bank/features/accounts/domain/entities/account.dart';
import 'package:digital_bank/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:digital_bank/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAccountsRepository implements AccountsRepository {
  _FakeAccountsRepository({this.result, this.delay});

  final Result<List<Account>>? result;
  final Duration? delay;

  @override
  Future<Result<List<Account>>> fetchAccounts() async {
    if (delay != null) {
      await Future<void>.delayed(delay!);
    }
    return result ?? const Success<List<Account>>([]);
  }
}

Widget _wrap(AccountsRepository repository) {
  return ProviderScope(
    overrides: [accountsRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: AccountsScreen()),
  );
}

void main() {
  group('AccountsScreen', () {
    testWidgets('WID-ACC-001 shows the loading state', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _FakeAccountsRepository(
            result: const Success<List<Account>>([]),
            delay: const Duration(seconds: 1),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('accounts_loading')), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('WID-ACC-002 renders accounts and balances', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _FakeAccountsRepository(
            result: const Success<List<Account>>([
              Account(
                id: 'acc-1',
                type: AccountType.savings,
                displayName: 'Savings Account',
                maskedNumber: '****1234',
                availableBalance: 1500.5,
              ),
              Account(
                id: 'acc-2',
                type: AccountType.checking,
                displayName: 'Checking Account',
                maskedNumber: '****5678',
                availableBalance: 20.0,
              ),
            ]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('account_card_acc-1')), findsOneWidget);
      expect(find.byKey(const Key('account_card_acc-2')), findsOneWidget);
      expect(find.text('Savings Account'), findsOneWidget);
      expect(find.text('****1234'), findsOneWidget);
      expect(find.text('\$1,500.50'), findsOneWidget);
      expect(find.text('\$20.00'), findsOneWidget);
    });

    testWidgets('WID-ACC-003 shows the error state', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _FakeAccountsRepository(
            result: const Failure<List<Account>>(ApiError(statusCode: 500)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('accounts_error')), findsOneWidget);
    });

    testWidgets('shows the empty state when there are no accounts', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          _FakeAccountsRepository(result: const Success<List<Account>>([])),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('accounts_empty')), findsOneWidget);
    });
  });
}
