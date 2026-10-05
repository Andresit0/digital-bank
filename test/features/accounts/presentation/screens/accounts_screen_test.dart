import 'package:digital_bank/features/accounts/di/accounts_providers.dart';
import 'package:digital_bank/features/accounts/domain/entities/account.dart';
import 'package:digital_bank/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:digital_bank/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';
import 'package:digital_bank/shared/read.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAccountsRepository implements AccountsRepository {
  _FakeAccountsRepository({this.result, this.delay});

  final Result<Read<List<Account>>>? result;
  final Duration? delay;

  @override
  Future<Result<Read<List<Account>>>> fetchAccounts() async {
    if (delay != null) {
      await Future<void>.delayed(delay!);
    }
    return result ??
        const Success<Read<List<Account>>>(
          Read<List<Account>>([], source: ReadSource.remote),
        );
  }
}

Widget _wrap(AccountsRepository repository) {
  return ProviderScope(
    overrides: [accountsRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: AccountsScreen()),
  );
}

const _account = Account(
  id: 'acc-1',
  type: AccountType.savings,
  displayName: 'Savings Account',
  maskedNumber: '****1234',
  availableBalance: 1500.5,
);

const _checking = Account(
  id: 'acc-2',
  type: AccountType.checking,
  displayName: 'Checking Account',
  maskedNumber: '****5678',
  availableBalance: 20.0,
);

void main() {
  group('AccountsScreen', () {
    testWidgets('WID-ACC-001 shows the loading state', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _FakeAccountsRepository(
            result: const Success<Read<List<Account>>>(
              Read<List<Account>>([], source: ReadSource.remote),
            ),
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
            result: const Success<Read<List<Account>>>(
              Read<List<Account>>(
                [_account, _checking],
                source: ReadSource.remote,
              ),
            ),
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
            result: const Failure<Read<List<Account>>>(
              ApiError(statusCode: 500),
            ),
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
          _FakeAccountsRepository(
            result: const Success<Read<List<Account>>>(
              Read<List<Account>>([], source: ReadSource.remote),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('accounts_empty')), findsOneWidget);
    });

    testWidgets('WID-ACC-004 stale accounts render usable accounts', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          _FakeAccountsRepository(
            result: const Success<Read<List<Account>>>(
              Read<List<Account>>([_account], source: ReadSource.cache),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('account_card_acc-1')), findsOneWidget);
      expect(find.text('Savings Account'), findsOneWidget);
    });

    testWidgets('WID-ACC-005 stale state exposes a retry action', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          _FakeAccountsRepository(
            result: const Success<Read<List<Account>>>(
              Read<List<Account>>([_account], source: ReadSource.cache),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('accounts_retry')), findsOneWidget);
    });
  });
}
