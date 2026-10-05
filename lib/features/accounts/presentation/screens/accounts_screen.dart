import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/presentation/theme/app_colors.dart';
import '../../../../shared/presentation/widgets/bank_app_bar.dart';
import '../accounts_state.dart';
import '../notifiers/accounts_notifier.dart';
import '../widgets/account_card.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key, this.selectForMovements = false});

  final bool selectForMovements;

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(accountsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountsProvider);
    final selectForMovements = widget.selectForMovements;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BankAppBar(
        title: selectForMovements ? 'Select an account' : 'My accounts',
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: switch (state) {
                AccountsInitial() || AccountsLoading() => const Center(
                  key: Key('accounts_loading'),
                  child: CircularProgressIndicator(color: AppColors.orange),
                ),
                AccountsEmpty() => const _AccountsEmptyState(),
                AccountsFailure() => const _AccountsErrorState(),
                AccountsLoaded(:final accounts) => ListView(
                  children: [
                    _AccountsHeader(selectForMovements: selectForMovements),
                    const SizedBox(height: 28),
                    Text(
                      'Your accounts',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final account in accounts) ...[
                      AccountCard(
                        account: account,
                        onTap: () => context.push(
                          Uri(
                            path: '/movements',
                            queryParameters: {'accountId': account.id},
                          ).toString(),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountsHeader extends StatelessWidget {
  const _AccountsHeader({required this.selectForMovements});

  final bool selectForMovements;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.orange,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectForMovements ? 'Choose your account' : 'Welcome back',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  selectForMovements
                      ? 'Choose the account whose movements you want to view.'
                      : 'Manage your money in one place',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountsEmptyState extends StatelessWidget {
  const _AccountsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('accounts_empty'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.orangeSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.orange,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No accounts available',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your accounts will appear here when they become available.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountsErrorState extends StatelessWidget {
  const _AccountsErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('accounts_error'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.orangeSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                color: AppColors.orange,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'We could not load your accounts. Please try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
