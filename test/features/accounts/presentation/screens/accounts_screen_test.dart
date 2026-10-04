import 'package:digital_bank/features/accounts/di/accounts_providers.dart';
import 'package:digital_bank/features/accounts/domain/entities/account.dart';
import 'package:digital_bank/features/accounts/domain/errors/accounts_error.dart';
import 'package:digital_bank/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:digital_bank/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAccountsRepository implements AccountsRepository {
  _FakeAccountsRepository({this.accounts, this.error, this.delay});

  final List<Account>? accounts;
  final Object? error;
  final Duration? delay;

  @override
  Future<List<Account>> fetchAccounts() async {
    if (delay != null) {
      await Future<void>.delayed(delay!);
    }
    if (error != null) {
      throw error!;
    }
    return accounts!;
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
            accounts: const [],
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
            accounts: const [
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
            ],
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
        _wrap(_FakeAccountsRepository(error: AccountsError.network)),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('accounts_error')), findsOneWidget);
    });

    testWidgets('shows the empty state when there are no accounts', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(_FakeAccountsRepository(accounts: const [])),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('accounts_empty')), findsOneWidget);
    });
  });
}
